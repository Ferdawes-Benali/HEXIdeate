"""
demo.py
───────
Standalone demo loop — run this to test the full pipeline on your webcam.

    python -m services.vision-service.demo

Keys:
  q / ESC  → quit
  s        → save current frame as snapshot.jpg
  v        → trigger a 10-second verification session (blocking)
"""

import sys
import time
import logging

import cv2
import numpy as np

logging.basicConfig(level=logging.INFO, format="%(levelname)s | %(message)s")

# Adjust import path when running as a script
try:
    from behavior_detector import BehaviorDetector, BehaviorResult
    from med_verifier      import MedVerifier,      MedVerifyResult
    from object_detector   import ObjectDetector,   ObjectDetectionResult
    from detector          import VisionPipeline,   _draw_realtime_hints
except ImportError:
    from services.vision_service.behavior_detector import BehaviorDetector, BehaviorResult
    from services.vision_service.med_verifier      import MedVerifier,      MedVerifyResult
    from services.vision_service.object_detector   import ObjectDetector,   ObjectDetectionResult
    from services.vision_service.detector          import VisionPipeline,   _draw_realtime_hints


# ──────────────────────────────────────────────
# Colour palette
# ──────────────────────────────────────────────

PALETTE = {
    "TAKEN":      (50,  205, 50),
    "UNCERTAIN":  (0,   165, 255),
    "NOT_TAKEN":  (0,   50,  220),
    "CORRECT":    (50,  205, 50),
    "WRONG":      (0,   50,  220),
}


def _color(label: str) -> tuple:
    return PALETTE.get(label, (180, 180, 180))


# ──────────────────────────────────────────────
# HUD overlay
# ──────────────────────────────────────────────

def draw_hud(frame: np.ndarray,
             behav:  BehaviorResult,
             verify: MedVerifyResult,
             obj:    ObjectDetectionResult,
             fps:    float) -> np.ndarray:
    """Draw a clean HUD on the demo frame."""
    h, w = frame.shape[:2]

    # Semi-transparent dark panel at bottom
    overlay = frame.copy()
    cv2.rectangle(overlay, (0, h - 120), (w, h), (20, 20, 30), -1)
    cv2.addWeighted(overlay, 0.65, frame, 0.35, 0, frame)

    # ── Behavior row ──────────────────────────
    b_col = _color(behav.label)
    cv2.putText(frame, f"BEHAVIOR  {behav.label}  score:{behav.score}",
                (12, h - 92), cv2.FONT_HERSHEY_SIMPLEX, 0.62, b_col, 2)

    # Score bar
    bar_w = int((min(behav.score, 100) / 100) * (w - 24))
    cv2.rectangle(frame, (12, h - 78), (12 + bar_w, h - 66), b_col, -1)
    cv2.rectangle(frame, (12, h - 78), (w - 12,     h - 66), (100, 100, 110), 1)

    # ── Verification row ──────────────────────
    v_col = _color(verify.label)
    med_str = f"{verify.matched_name} {verify.matched_dose}" if verify.matched_name else "—"
    cv2.putText(frame, f"MED  {verify.label}  {med_str}  ({verify.confidence:.0%})",
                (12, h - 46), cv2.FONT_HERSHEY_SIMPLEX, 0.62, v_col, 2)

    # ── Feedback ──────────────────────────────
    feedback = verify.feedback or behav.feedback
    cv2.putText(frame, feedback, (12, h - 16),
                cv2.FONT_HERSHEY_SIMPLEX, 0.52, (220, 220, 220), 1)

    # ── FPS / object badge ────────────────────
    badge = f"FPS {fps:.0f}"
    if obj.med_object_present:
        badge += "  📦 med detected"
    cv2.putText(frame, badge, (w - 200, 28),
                cv2.FONT_HERSHEY_SIMPLEX, 0.52, (180, 180, 180), 1)

    return frame


# ──────────────────────────────────────────────
# Main loop
# ──────────────────────────────────────────────

def run_demo(camera: int = 0):
    behavior  = BehaviorDetector()
    verifier  = MedVerifier()           # uses default prescription
    detector  = ObjectDetector()        # COCO nano; swap for custom model

    cap = cv2.VideoCapture(camera)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH,  640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

    if not cap.isOpened():
        logging.error("Cannot open camera %d", camera)
        sys.exit(1)

    logging.info("Demo running. Press 'q' to quit, 's' to snapshot, 'v' to verify.")

    prev_time  = time.time()
    behav      = BehaviorResult()
    verify     = MedVerifyResult()
    obj        = ObjectDetectionResult()
    frame_no   = 0

    while True:
        ok, frame = cap.read()
        if not ok:
            logging.warning("Frame grab failed.")
            continue

        frame_no += 1

        # ── Object detection (every 3 frames for speed) ───────────────────
        if frame_no % 3 == 0:
            obj = detector.detect(frame)
            frame = detector.draw_boxes(frame, obj)

        # ── Behavior analysis (every frame) ───────────────────────────────
        behav = behavior.process_frame(frame)

        # ── Medication verification (on demand when med visible) ──────────
        if obj.med_object_present and frame_no % 15 == 0:
            verify = verifier.verify(frame)

        # ── Real-time hints ───────────────────────────────────────────────
        _draw_realtime_hints(frame, behav, verify)

        # ── HUD ───────────────────────────────────────────────────────────
        now = time.time()
        fps = 1.0 / max(now - prev_time, 1e-6)
        prev_time = now
        frame = draw_hud(frame, behav, verify, obj, fps)

        cv2.imshow("DwaFi  —  Medication Vision System", frame)

        key = cv2.waitKey(1) & 0xFF
        if key in (ord("q"), 27):
            break
        elif key == ord("s"):
            fname = f"snapshot_{int(time.time())}.jpg"
            cv2.imwrite(fname, frame)
            logging.info("Saved %s", fname)
        elif key == ord("v"):
            # Trigger a dedicated verification session
            logging.info("Starting 10-second verification session …")
            pipeline = VisionPipeline()
            output   = pipeline.run_session(duration_s=10.0, show_ui=True)
            logging.info("Session result: %s", output.to_agent_dict())

    cap.release()
    behavior.release()
    cv2.destroyAllWindows()
    logging.info("Demo closed.")


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="DwaFi Vision Demo")
    parser.add_argument("--camera", type=int, default=0, help="Camera index")
    args = parser.parse_args()
    run_demo(args.camera)