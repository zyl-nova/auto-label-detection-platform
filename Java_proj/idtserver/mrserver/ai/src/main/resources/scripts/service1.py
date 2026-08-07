import argparse
import json
import os
import sys
import time
from pathlib import Path

import cv2

config_dir = Path(os.environ.get("YOLO_CONFIG_DIR", Path(__file__).resolve().parent / "ultralytics_config"))
config_dir.mkdir(parents=True, exist_ok=True)
os.environ["YOLO_CONFIG_DIR"] = str(config_dir)

from ultralytics import YOLO


IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def parse_args():
    parser = argparse.ArgumentParser(description="Watch a camera import folder and run YOLO detection.")
    parser.add_argument("--watch-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--model", required=True)
    parser.add_argument("--conf", type=float, default=0.25)
    parser.add_argument("--interval", type=float, default=2.0)
    return parser.parse_args()


def image_files(folder: Path):
    if not folder.exists():
        return []
    return [
        path for path in folder.iterdir()
        if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
    ]


def wait_until_complete(path: Path):
    try:
        first_size = path.stat().st_size
        time.sleep(0.3)
        return first_size > 0 and first_size == path.stat().st_size
    except OSError:
        return False


def detect_single_image(model, image_path: Path, confidence: float):
    image = cv2.imread(str(image_path))
    if image is None:
        return {"image": image_path.name, "detections": []}, None, None

    height, width = image.shape[:2]
    predictions = model.predict(source=str(image_path), conf=confidence, verbose=False)
    detections = []
    next_id = 1
    for prediction in predictions:
        for box in prediction.boxes:
            class_id = int(box.cls[0])
            score = float(box.conf[0])
            x1, y1, x2, y2 = box.xyxy[0].tolist()
            detections.append({
                "id": next_id,
                "label": prediction.names[class_id],
                "confidence": round(score * 100, 2),
                "x": round(x1 / width * 100, 2),
                "y": round(y1 / height * 100, 2),
                "width": round((x2 - x1) / width * 100, 2),
                "height": round((y2 - y1) / height * 100, 2),
            })
            next_id += 1

    annotated_image = predictions[0].plot() if predictions else image.copy()
    return {"image": image_path.name, "detections": detections}, annotated_image, image


def save_result(output_dir: Path, filename: str, result, annotated_image, original_image):
    detected_path = output_dir / f"det_{filename}"
    original_path = output_dir / f"orig_{filename}"
    json_path = output_dir / f"det_{Path(filename).stem}.json"

    cv2.imwrite(str(detected_path), annotated_image)
    cv2.imwrite(str(original_path), original_image)

    detections = []
    for item in result.get("detections", []):
        x = item.get("x", 0)
        y = item.get("y", 0)
        width = item.get("width", 0)
        height = item.get("height", 0)
        detections.append({
            "class": item.get("label", "unknown"),
            "confidence": item.get("confidence", 0) / 100,
            "bbox": [x, y, x + width, y + height],
        })

    payload = {
        "filename": filename,
        "originalImage": f"/results/{original_path.name}",
        "detectedImage": f"/results/{detected_path.name}",
        "detections": detections,
    }
    json_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def main():
    args = parse_args()
    watch_dir = Path(args.watch_dir).resolve()
    output_dir = Path(args.output_dir).resolve()
    watch_dir.mkdir(parents=True, exist_ok=True)
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Watching: {watch_dir}", flush=True)
    print(f"Results: {output_dir}", flush=True)
    print(f"Model: {args.model}", flush=True)

    model = YOLO(args.model)
    processed = {str(path.resolve()) for path in image_files(watch_dir)}

    while True:
        try:
            for image_path in image_files(watch_dir):
                resolved = str(image_path.resolve())
                if resolved in processed or not wait_until_complete(image_path):
                    continue
                result, annotated_image, original_image = detect_single_image(model, image_path, args.conf)
                if annotated_image is not None and original_image is not None:
                    save_result(output_dir, image_path.name, result, annotated_image, original_image)
                    print(json.dumps({"type": "real_time", "data": result}, ensure_ascii=False), flush=True)
                processed.add(resolved)
            time.sleep(max(0.5, args.interval))
        except KeyboardInterrupt:
            break
        except Exception as error:
            print(f"Camera watcher error: {error}", file=sys.stderr, flush=True)
            time.sleep(max(0.5, args.interval))


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(json.dumps({"error": str(error)}, ensure_ascii=False), file=sys.stderr)
        sys.exit(1)
