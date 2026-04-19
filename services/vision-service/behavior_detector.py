"""
behavior_detector.py
────────────────────
Tracks pill-taking behavior using MediaPipe pose + hand + face landmarks.
Works on individual frames; the caller owns the time window / rolling buffer.

Scoring rubric
  hand_to_mouth   → +40
  object_in_hand  → +20
  drinking_motion → +20
  area_proximity  → +10
  ─────────────────────
  ≥ 70 → TAKEN  |  40-69 → UNCERTAIN  |  < 40 → NOT_TAKEN
"""

import cv2
import mediapipe as mp
import numpy as np
from dataclasses import dataclass, field
from collections import deque
from typing import Optional

# ──────────────────────────────────────────────
# Data structures
# ──────────────────────────────────────────────

@dataclass
class FrameEvidence:
    """Evidence extracted from a single frame."""
    person_present: bool = False
    hand_to_mouth: bool = False
    object_in_hand: bool = False      # proxied via hand-closure heuristic
    drinking_motion: bool = False
    area_proximity: bool = False      # hand stays in upper-body region
    raw_score: int = 0


@dataclass
class BehaviorResult:
    """Aggregated result over the rolling window."""
    label: str = "NOT_TAKEN"          # TAKEN | UNCERTAIN | NOT_TAKEN
    confidence: float = 0.0           # 0-1
    score: int = 0                    # raw aggregate score
    evidence: dict = field(default_factory=dict)
    feedback: str = ""                # real-time guidance string


# ──────────────────────────────────────────────
# Constants / thresholds
# ──────────────────────────────────────────────

SCORE_HAND_TO_MOUTH  = 40
SCORE_OBJECT_IN_HAND = 20
SCORE_DRINKING       = 20
SCORE_AREA_PROXIMITY = 10

THRESHOLD_TAKEN     = 70
THRESHOLD_UNCERTAIN = 40

# How many consecutive frames must show evidence before it counts
FRAME_CONFIRM_COUNT = 3

# Rolling window size (frames)
WINDOW_SIZE = 90   # ≈ 3 s at 30 fps


# ──────────────────────────────────────────────
# Detector class
# ──────────────────────────────────────────────

class BehaviorDetector:
    """
    Stateful detector. Call `process_frame(bgr_frame)` for each camera frame.
    It maintains an internal rolling buffer and returns an up-to-date
    BehaviorResult on every call.
    """

    def __init__(self, window_size: int = WINDOW_SIZE):
        self.window_size = window_size
        self._buffer: deque[FrameEvidence] = deque(maxlen=window_size)

        # MediaPipe solutions
        self._mp_pose  = mp.solutions.pose
        self._mp_hands = mp.solutions.hands
        self._mp_face  = mp.solutions.face_mesh

        self.pose = self._mp_pose.Pose(
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5,
            model_complexity=0          # lightweight for mobile
        )
        self.hands = self._mp_hands.Hands(
            max_num_hands=2,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        self.face = self._mp_face.FaceMesh(
            max_num_faces=1,
            refine_landmarks=False,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )

        # Confirm-counter state (debounce fleeting detections)
        self._htm_counter = 0   # hand-to-mouth frames seen consecutively

    # ── Public API ─────────────────────────────

    def process_frame(self, bgr: np.ndarray) -> BehaviorResult:
        """
        Analyse one BGR frame and return the latest aggregated BehaviorResult.
        """
        rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
        rgb.flags.writeable = False

        pose_res  = self.pose.process(rgb)
        hand_res  = self.hands.process(rgb)
        face_res  = self.face.process(rgb)

        rgb.flags.writeable = True

        ev = self._extract_evidence(bgr, pose_res, hand_res, face_res)
        self._buffer.append(ev)

        return self._aggregate()

    def draw_debug(self, bgr: np.ndarray, result: BehaviorResult) -> np.ndarray:
        """Overlay landmarks and score info on the frame (for demo loop)."""
        mp.solutions.drawing_utils.draw_landmarks(
            bgr,
            None  # landmarks drawn inside process() by MediaPipe if needed
        )
        colour = (0, 200, 0) if result.label == "TAKEN" else \
                 (0, 165, 255) if result.label == "UNCERTAIN" else \
                 (0, 0, 220)
        cv2.putText(bgr, f"{result.label}  ({result.score})",
                    (12, 36), cv2.FONT_HERSHEY_SIMPLEX, 1.1, colour, 2)
        cv2.putText(bgr, result.feedback,
                    (12, 68), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (220, 220, 220), 1)
        return bgr

    def release(self):
        self.pose.close()
        self.hands.close()
        self.face.close()

    # ── Private helpers ─────────────────────────

    def _extract_evidence(self, bgr, pose_res, hand_res, face_res) -> FrameEvidence:
        h, w = bgr.shape[:2]
        ev = FrameEvidence()

        # ── 1. Person present ──────────────────
        if pose_res.pose_landmarks:
            ev.person_present = True
        else:
            return ev   # no person → nothing else matters

        # ── 2. Mouth position (face mesh landmark 13 = inner upper lip) ──
        mouth_pt: Optional[tuple] = None
        if face_res.multi_face_landmarks:
            lm = face_res.multi_face_landmarks[0].landmark[13]
            mouth_pt = (lm.x * w, lm.y * h)

        # Fall back to pose nose as rough mouth proxy
        if mouth_pt is None and pose_res.pose_landmarks:
            nose = pose_res.pose_landmarks.landmark[
                self._mp_pose.PoseLandmark.NOSE]
            mouth_pt = (nose.x * w, (nose.y + 0.04) * h)

        # ── 3. Hand landmarks ──────────────────
        if hand_res.multi_hand_landmarks and mouth_pt:
            for hand_lm in hand_res.multi_hand_landmarks:
                # Wrist + index tip for distance
                wrist   = hand_lm.landmark[0]
                idx_tip = hand_lm.landmark[8]

                wx, wy = wrist.x   * w, wrist.y   * h
                ix, iy = idx_tip.x * w, idx_tip.y * h

                # Distance from index finger tip to mouth
                dist_to_mouth = np.hypot(ix - mouth_pt[0], iy - mouth_pt[1])

                # Threshold: 10 % of frame height is "at mouth"
                if dist_to_mouth < h * 0.10:
                    self._htm_counter += 1
                    if self._htm_counter >= FRAME_CONFIRM_COUNT:
                        ev.hand_to_mouth = True
                else:
                    self._htm_counter = max(0, self._htm_counter - 1)

                # Object-in-hand: finger curl heuristic
                # thumb tip (4) vs thumb base (2) distance
                t_tip  = hand_lm.landmark[4]
                t_base = hand_lm.landmark[2]
                curl = np.hypot((t_tip.x - t_base.x) * w,
                                (t_tip.y - t_base.y) * h)
                if curl < w * 0.05:   # thumb curled inward → gripping
                    ev.object_in_hand = True

                # Drinking motion: wrist is ABOVE elbow and close to mouth
                elbow = pose_res.pose_landmarks.landmark[
                    self._mp_pose.PoseLandmark.LEFT_ELBOW
                    if wrist.x < 0.5 else
                    self._mp_pose.PoseLandmark.RIGHT_ELBOW]
                ely = elbow.y * h
                if wy < ely and dist_to_mouth < h * 0.18:
                    ev.drinking_motion = True

                # Area proximity: hand in upper-body region (y < 60 % of frame)
                if wy < h * 0.60:
                    ev.area_proximity = True

        # ── 4. Raw frame score ─────────────────
        ev.raw_score = (
            (SCORE_HAND_TO_MOUTH  if ev.hand_to_mouth  else 0) +
            (SCORE_OBJECT_IN_HAND if ev.object_in_hand else 0) +
            (SCORE_DRINKING       if ev.drinking_motion else 0) +
            (SCORE_AREA_PROXIMITY if ev.area_proximity  else 0)
        )
        return ev

    def _aggregate(self) -> BehaviorResult:
        """Compute rolling-window result from the buffer."""
        if not self._buffer:
            return BehaviorResult(label="NOT_TAKEN", feedback="No data yet.")

        total   = len(self._buffer)
        present = sum(1 for e in self._buffer if e.person_present)

        if present == 0:
            return BehaviorResult(
                label="NOT_TAKEN",
                feedback="No person detected. Please face the camera.",
            )

        # Average score over frames where a person was visible
        avg_score = np.mean([e.raw_score for e in self._buffer if e.person_present])

        # Evidence proportions (for confidence + feedback)
        htm_rate = sum(1 for e in self._buffer if e.hand_to_mouth) / total
        obj_rate = sum(1 for e in self._buffer if e.object_in_hand) / total
        drk_rate = sum(1 for e in self._buffer if e.drinking_motion) / total

        # Classification
        if avg_score >= THRESHOLD_TAKEN:
            label = "TAKEN"
            confidence = min(1.0, avg_score / 100)
            feedback = "✓ Medication likely taken. Good job!"
        elif avg_score >= THRESHOLD_UNCERTAIN:
            label = "UNCERTAIN"
            confidence = avg_score / 100
            feedback = "Hold the medicine near your mouth for a moment."
        else:
            label = "NOT_TAKEN"
            confidence = 1 - (avg_score / THRESHOLD_TAKEN)
            if not any(e.person_present for e in self._buffer):
                feedback = "Please face the camera."
            elif htm_rate < 0.1:
                feedback = "Bring your hand closer to your mouth."
            else:
                feedback = "Keep the gesture steady for a few seconds."

        return BehaviorResult(
            label=label,
            confidence=round(float(confidence), 2),
            score=int(avg_score),
            evidence={
                "hand_to_mouth_rate": round(htm_rate, 2),
                "object_in_hand_rate": round(obj_rate, 2),
                "drinking_motion_rate": round(drk_rate, 2),
            },
            feedback=feedback,
        )