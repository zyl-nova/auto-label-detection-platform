import argparse
import json
import os
import sys
from pathlib import Path

import cv2

config_dir = Path(os.environ.get("YOLO_CONFIG_DIR", Path(__file__).resolve().parent / "ultralytics_config"))
config_dir.mkdir(parents=True, exist_ok=True)
os.environ["YOLO_CONFIG_DIR"] = str(config_dir)

from ultralytics import YOLO


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--image", required=True)
    parser.add_argument("--model", required=True)
    parser.add_argument("--conf", type=float, default=0.25)
    args = parser.parse_args()

    image = cv2.imread(args.image)
    if image is None:
        raise RuntimeError(f"Cannot read image: {args.image}")

    image_height, image_width = image.shape[:2]
    model = YOLO(args.model)
    predictions = model.predict(source=args.image, conf=args.conf, verbose=False)

    items = []
    next_id = 1
    for prediction in predictions:
        names = prediction.names
        for box in prediction.boxes:
            x1, y1, x2, y2 = box.xyxy[0].tolist()
            class_id = int(box.cls[0].item())
            confidence = float(box.conf[0].item())
            items.append({
                "id": next_id,
                "label": names.get(class_id, str(class_id)),
                "confidence": round(confidence * 100, 2),
                "x": round(x1 / image_width * 100, 2),
                "y": round(y1 / image_height * 100, 2),
                "width": round((x2 - x1) / image_width * 100, 2),
                "height": round((y2 - y1) / image_height * 100, 2),
            })
            next_id += 1

    print(json.dumps({"results": items}, ensure_ascii=False))


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(json.dumps({"error": str(exc)}, ensure_ascii=False), file=sys.stderr)
        sys.exit(1)
