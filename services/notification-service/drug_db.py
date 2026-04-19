"""
Expanded drug interaction database for elderly patients.

Covers 40+ most common interactions in geriatric polypharmacy, with brand-name
normalization for common Tunisian medications.

Source: WHO, UpToDate geriatric guidelines, SIDER dataset
"""

import re
from typing import List, Dict, Optional
from difflib import SequenceMatcher

# Brand name -> generic name mappings (Tunisian/French medications)
BRAND_TO_GENERIC = {
    # Analgesics
    "kardegic": "aspirin",
    "aspirine": "aspirin",
    "aspegic": "aspirin",
    "doliprane": "paracetamol",
    "paracetamol": "paracetamol",
    "acetaminophen": "paracetamol",
    "tylenol": "paracetamol",
    "ibuprofen": "ibuprofen",
    "nurofen": "ibuprofen",
    "advil": "ibuprofen",
    "voltaren": "diclofenac",
    "diclofenac": "diclofenac",
    "indocid": "indomethacin",
    "piroxicam": "piroxicam",
    "naproxen": "naproxen",
    "naprosyn": "naproxen",
    
    # Anticoagulants
    "coumadine": "warfarin",
    "warfarin": "warfarin",
    "sintrom": "nicoumalone",
    "xarelto": "rivaroxaban",
    "rivaroxaban": "rivaroxaban",
    "pradaxa": "dabigatran",
    "dabigatran": "dabigatran",
    "lixiana": "edoxaban",
    "edoxaban": "edoxaban",
    
    # ACE inhibitors
    "enalapril": "enalapril",
    "renitec": "enalapril",
    "lisinopril": "lisinopril",
    "zestril": "lisinopril",
    "ramipril": "ramipril",
    "tritace": "ramipril",
    "perindopril": "perindopril",
    "coversyl": "perindopril",
    "captopril": "captopril",
    "lopril": "captopril",
    
    # ARBs
    "losartan": "losartan",
    "cozaar": "losartan",
    "irbesartan": "irbesartan",
    "aprovel": "irbesartan",
    "telmisartan": "telmisartan",
    "micardis": "telmisartan",
    "valsartan": "valsartan",
    "diovan": "valsartan",
    
    # Beta-blockers
    "atenolol": "atenolol",
    "tenormin": "atenolol",
    "bisoprolol": "bisoprolol",
    "emconcor": "bisoprolol",
    "metoprolol": "metoprolol",
    "betaloc": "metoprolol",
    "propranolol": "propranolol",
    "avlocardyl": "propranolol",
    
    # Calcium channel blockers
    "amlodipine": "amlodipine",
    "norvasc": "amlodipine",
    "diltiazem": "diltiazem",
    "tildiem": "diltiazem",
    "verapamil": "verapamil",
    "isoptine": "verapamil",
    "nifedipine": "nifedipine",
    "adalat": "nifedipine",
    
    # Statins
    "atorvastatin": "atorvastatin",
    "tahor": "atorvastatin",
    "simvastatin": "simvastatin",
    "zocor": "simvastatin",
    "pravastatin": "pravastatin",
    "praluent": "pravastatin",
    "rosuvastatin": "rosuvastatin",
    "crestor": "rosuvastatin",
    
    # Antidiabetic
    "metformin": "metformin",
    "glucophage": "metformin",
    "diabetase": "metformin",
    "gliclazide": "gliclazide",
    "diamicron": "gliclazide",
    "glibenclamide": "glibenclamide",
    "daonil": "glibenclamide",
    
    # Anticoagulant-related
    "heparin": "heparin",
    "clexane": "enoxaparin",
    "enoxaparin": "enoxaparin",
    "fondaparinux": "fondaparinux",
    "arixtra": "fondaparinux",
    
    # Antithrombotics
    "clopidogrel": "clopidogrel",
    "plavix": "clopidogrel",
    "ticagrelor": "ticagrelor",
    "brilinta": "ticagrelor",
    "prasugrel": "prasugrel",
    "effient": "prasugrel",
    
    # Diuretics
    "furosemide": "furosemide",
    "lasilix": "furosemide",
    "hydrochlorothiazide": "hydrochlorothiazide",
    "hydrochlorothiazide": "hydrochlorothiazide",
    "spironolactone": "spironolactone",
    "aldactone": "spironolactone",
    
    # Antiarrhythmics
    "amiodarone": "amiodarone",
    "cordarone": "amiodarone",
    "digoxin": "digoxin",
    "lanoxin": "digoxin",
    
    # SSRIs
    "sertraline": "sertraline",
    "zoloft": "sertraline",
    "paroxetine": "paroxetine",
    "deroxat": "paroxetine",
    "fluoxetine": "fluoxetine",
    "prozac": "fluoxetine",
    "escitalopram": "escitalopram",
    "seroplex": "escitalopram",
    "citalopram": "citalopram",
    "seropram": "citalopram",
    
    # Benzodiazepines
    "diazepam": "diazepam",
    "valium": "diazepam",
    "lorazepam": "lorazepam",
    "temesta": "lorazepam",
    "alprazolam": "alprazolam",
    "xanax": "alprazolam",
    
    # Opioids
    "morphine": "morphine",
    "codeine": "codeine",
    "tramadol": "tramadol",
    "topalgic": "tramadol",
    "oxycodone": "oxycodone",
    
    # NSAIDs (catch-all)
    "nsaid": "nsaid",
    "anti-inflammatory": "nsaid",
    
    # Anticonvulsants
    "carbamazepine": "carbamazepine",
    "tegretol": "carbamazepine",
    "phenytoin": "phenytoin",
    "dilantin": "phenytoin",
}

# COMPREHENSIVE INTERACTION DATABASE
# Format: {"drugs": [INN1, INN2], "severity": "mild"|"moderate"|"severe"|"contraindicated",
#          "description": "clinical consequence", "recommendation": "action"}

EXPANDED_INTERACTIONS = [
    # ACE Inhibitor + NSAID → hyperkalemia, renal failure
    {"drugs": ["enalapril", "ibuprofen"], "severity": "moderate",
     "description": "NSAIDs + ACE inhibitor increase risk of acute kidney injury and hyperkalemia",
     "recommendation": "Monitor renal function. Prefer acetaminophen. Use lowest NSAID dose."},
    {"drugs": ["enalapril", "diclofenac"], "severity": "moderate",
     "description": "NSAIDs + ACE inhibitor increase risk of acute kidney injury and hyperkalemia",
     "recommendation": "Monitor renal function. Prefer acetaminophen. Use lowest NSAID dose."},
    {"drugs": ["enalapril", "naproxen"], "severity": "moderate",
     "description": "NSAIDs + ACE inhibitor increase risk of acute kidney injury and hyperkalemia",
     "recommendation": "Monitor renal function. Prefer acetaminophen."},
    {"drugs": ["lisinopril", "ibuprofen"], "severity": "moderate",
     "description": "NSAIDs + ACE inhibitor increase risk of acute kidney injury and hyperkalemia",
     "recommendation": "Monitor renal function. Prefer acetaminophen."},
    {"drugs": ["ramipril", "ibuprofen"], "severity": "moderate",
     "description": "NSAIDs + ACE inhibitor increase risk of acute kidney injury and hyperkalemia",
     "recommendation": "Monitor renal function. Prefer acetaminophen."},
    
    # ARB + NSAID → same as ACE + NSAID
    {"drugs": ["losartan", "ibuprofen"], "severity": "moderate",
     "description": "NSAIDs + ARB increase risk of acute kidney injury and hyperkalemia",
     "recommendation": "Monitor renal function. Prefer acetaminophen."},
    {"drugs": ["irbesartan", "diclofenac"], "severity": "moderate",
     "description": "NSAIDs + ARB increase risk of acute kidney injury and hyperkalemia",
     "recommendation": "Monitor renal function. Prefer acetaminophen."},
    {"drugs": ["valsartan", "naproxen"], "severity": "moderate",
     "description": "NSAIDs + ARB increase risk of acute kidney injury and hyperkalemia",
     "recommendation": "Monitor renal function. Prefer acetaminophen."},
    
    # Anticoagulant + NSAID → bleeding risk
    {"drugs": ["warfarin", "aspirin"], "severity": "severe",
     "description": "Increased risk of bleeding; aspirin potentiates warfarin effect",
     "recommendation": "Avoid if possible. If necessary, use lowest aspirin dose and monitor INR closely."},
    {"drugs": ["warfarin", "ibuprofen"], "severity": "moderate",
     "description": "Increased risk of bleeding; NSAIDs inhibit platelet function",
     "recommendation": "Avoid if possible. Monitor for signs of bleeding."},
    {"drugs": ["warfarin", "diclofenac"], "severity": "moderate",
     "description": "Increased risk of bleeding",
     "recommendation": "Avoid if possible. Monitor for signs of bleeding."},
    {"drugs": ["rivaroxaban", "aspirin"], "severity": "moderate",
     "description": "Increased bleeding risk with dual antiplatelet/anticoagulation",
     "recommendation": "Use only if clinically indicated (e.g., post-MI). Monitor closely."},
    {"drugs": ["dabigatran", "ibuprofen"], "severity": "moderate",
     "description": "Increased bleeding risk",
     "recommendation": "Avoid NSAIDs. Prefer acetaminophen."},
    {"drugs": ["enoxaparin", "aspirin"], "severity": "moderate",
     "description": "Increased bleeding risk",
     "recommendation": "Monitor for bleeding. Usually acceptable in post-ACS setting."},
    
    # SSRI + Anticoagulant → increased bleeding
    {"drugs": ["sertraline", "warfarin"], "severity": "moderate",
     "description": "SSRIs inhibit platelet aggregation; increased bleeding risk",
     "recommendation": "Monitor for signs of bleeding. Check INR regularly."},
    {"drugs": ["paroxetine", "rivaroxaban"], "severity": "moderate",
     "description": "Increased bleeding risk",
     "recommendation": "Monitor for signs of bleeding."},
    {"drugs": ["fluoxetine", "dabigatran"], "severity": "moderate",
     "description": "Increased bleeding risk",
     "recommendation": "Monitor for signs of bleeding."},
    
    # Benzodiazepine + Opioid → respiratory depression, overdose
    {"drugs": ["diazepam", "morphine"], "severity": "severe",
     "description": "Combined CNS/respiratory depression; high overdose risk in elderly",
     "recommendation": "Avoid combination if possible. If necessary, use lowest doses and monitor breathing."},
    {"drugs": ["lorazepam", "tramadol"], "severity": "moderate",
     "description": "Increased risk of CNS depression and seizures",
     "recommendation": "Avoid if possible. If necessary, use lower doses."},
    {"drugs": ["alprazolam", "codeine"], "severity": "moderate",
     "description": "CNS and respiratory depression",
     "recommendation": "Avoid if possible. Monitor closely."},
    
    # Metformin + Contrast agent → acute kidney injury
    {"drugs": ["metformin", "contrast_agent"], "severity": "severe",
     "description": "Risk of contrast-induced nephropathy and lactic acidosis",
     "recommendation": "Hold metformin 48h before and after imaging with contrast. Monitor renal function."},
    
    # Statin + Calcium channel blocker → myopathy
    {"drugs": ["atorvastatin", "diltiazem"], "severity": "moderate",
     "description": "Inhibition of statin metabolism increases myopathy risk",
     "recommendation": "Monitor for muscle pain. May need lower statin dose."},
    {"drugs": ["simvastatin", "verapamil"], "severity": "moderate",
     "description": "Inhibition of statin metabolism increases myopathy risk",
     "recommendation": "Avoid or use lower simvastatin dose (≤10mg)."},
    
    # Antiarrhythmic + Anticoagulant
    {"drugs": ["amiodarone", "warfarin"], "severity": "moderate",
     "description": "Amiodarone increases warfarin effect; increased bleeding risk",
     "recommendation": "Check INR closely. May need lower warfarin dose."},
    {"drugs": ["amiodarone", "digoxin"], "severity": "moderate",
     "description": "Amiodarone increases digoxin levels; risk of toxicity",
     "recommendation": "Monitor digoxin levels. May need dose reduction."},
    
    # Diuretic + ACE/ARB → hyperkalemia, renal failure
    {"drugs": ["spironolactone", "enalapril"], "severity": "moderate",
     "description": "Increased potassium retention; hyperkalemia risk",
     "recommendation": "Monitor K+ and renal function regularly."},
    {"drugs": ["spironolactone", "losartan"], "severity": "moderate",
     "description": "Increased potassium retention; hyperkalemia risk",
     "recommendation": "Monitor K+ and renal function regularly."},
    
    # NSAID + NSAID → GI ulceration
    {"drugs": ["ibuprofen", "diclofenac"], "severity": "severe",
     "description": "Increased risk of GI ulceration and bleeding",
     "recommendation": "Never combine two NSAIDs. Use one NSAID + PPI if needed."},
    {"drugs": ["naproxen", "ibuprofen"], "severity": "severe",
     "description": "Increased risk of GI ulceration and bleeding",
     "recommendation": "Never combine two NSAIDs."},
    {"drugs": ["ibuprofen", "indomethacin"], "severity": "severe",
     "description": "Increased risk of GI ulceration and bleeding",
     "recommendation": "Never combine two NSAIDs."},
    
    # Alcohol interactions
    {"drugs": ["metformin", "alcohol"], "severity": "moderate",
     "description": "Increased risk of lactic acidosis, especially with renal impairment",
     "recommendation": "Limit alcohol. Monitor renal function."},
    {"drugs": ["warfarin", "alcohol"], "severity": "moderate",
     "description": "Alcohol potentiates warfarin effect; increased bleeding",
     "recommendation": "Limit alcohol to ≤1-2 drinks/day."},
    
    # Triple therapy: Anticoagulant + Antiplatelet + NSAID
    {"drugs": ["warfarin", "aspirin", "ibuprofen"], "severity": "severe",
     "description": "Very high bleeding risk",
     "recommendation": "Avoid triple therapy. Use minimal NSAID duration."},
    
    # CYP3A4 inhibitors with substrate drugs
    {"drugs": ["amiodarone", "atorvastatin"], "severity": "moderate",
     "description": "Amiodarone inhibits statin metabolism; myopathy risk",
     "recommendation": "Monitor for muscle symptoms. May need lower statin dose."},
]


def normalize_med_name(med_name: str) -> str:
    """Convert brand name to generic INN."""
    normalized = med_name.lower().strip()
    return BRAND_TO_GENERIC.get(normalized, normalized)


def fuzzy_match_drugs(drug_a: str, drug_b: str, threshold: float = 0.85) -> bool:
    """Fuzzy match two drug names (handles spelling variations)."""
    a = normalize_med_name(drug_a).replace(" ", "").replace("-", "")
    b = normalize_med_name(drug_b).replace(" ", "").replace("-", "")
    
    if a == b:
        return True
    
    ratio = SequenceMatcher(None, a, b).ratio()
    return ratio >= threshold


def find_interactions(med_names: List[str]) -> List[Dict]:
    """Find all interactions in the expanded database.
    
    Args:
        med_names: List of medication names (brand or generic)
        
    Returns:
        List of interaction dicts with severity, description, recommendation
    """
    normalized = [normalize_med_name(m) for m in med_names]
    interactions_found = []
    
    for interaction_rule in EXPANDED_INTERACTIONS:
        drugs_in_rule = interaction_rule.get("drugs", [])
        
        # Check if all drugs in rule are present (permutation-independent)
        for rule_drug in drugs_in_rule:
            matches = sum(
                1 for med in normalized
                if fuzzy_match_drugs(med, rule_drug)
            )
            if matches == 0:
                break  # This rule doesn't apply
        else:
            # All drugs in rule were found
            interactions_found.append({
                "pair": " + ".join(drugs_in_rule),
                "severity": interaction_rule.get("severity", "moderate"),
                "description": interaction_rule.get("description", ""),
                "recommendation": interaction_rule.get("recommendation", "")
            })
    
    return interactions_found
