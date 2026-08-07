import argparse
import json
import shutil
import traceback
from pathlib import Path


def write_status(path, **values):
    current = {}
    if path.exists():
        try:
            current = json.loads(path.read_text(encoding="utf-8"))
        except Exception:
            current = {}
    current.update(values)
    temporary = path.with_suffix(".tmp")
    temporary.write_text(json.dumps(current, ensure_ascii=False, indent=2), encoding="utf-8")
    temporary.replace(path)


def origin_offset(value, size, origin):
    if origin == "center":
        return value - size / 2
    if origin in ("right", "bottom"):
        return value - size
    return value


def annotation_box(annotation, image_info):
    obj = annotation.get("fabricObj") or {}
    object_type = obj.get("type", "rect")
    scale_x = abs(float(obj.get("scaleX", 1) or 1))
    scale_y = abs(float(obj.get("scaleY", 1) or 1))
    width = float(obj.get("width", 0) or 0) * scale_x
    height = float(obj.get("height", 0) or 0) * scale_y
    if object_type == "circle":
        radius = float(obj.get("radius", 0) or 0)
        width = radius * 2 * scale_x
        height = radius * 2 * scale_y

    left = origin_offset(float(obj.get("left", 0) or 0), width, obj.get("originX", "left"))
    top = origin_offset(float(obj.get("top", 0) or 0), height, obj.get("originY", "top"))
    image_left = float(image_info.get("left", 0) or 0)
    image_top = float(image_info.get("top", 0) or 0)
    image_width = float(image_info.get("width", 0) or 0)
    image_height = float(image_info.get("height", 0) or 0)
    if width <= 0 or height <= 0 or image_width <= 0 or image_height <= 0:
        return None

    x1 = max(0.0, left - image_left)
    y1 = max(0.0, top - image_top)
    x2 = min(image_width, left - image_left + width)
    y2 = min(image_height, top - image_top + height)
    if x2 <= x1 or y2 <= y1:
        return None
    return (
        ((x1 + x2) / 2) / image_width,
        ((y1 + y2) / 2) / image_height,
        (x2 - x1) / image_width,
        (y2 - y1) / image_height,
    )


def prepare_dataset(manifest_path, job_dir, status_path):
    from PIL import Image

    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    items = manifest.get("items", [])
    dataset_dir = job_dir / "dataset"
    for split in ("train", "val"):
        (dataset_dir / "images" / split).mkdir(parents=True, exist_ok=True)
        (dataset_dir / "labels" / split).mkdir(parents=True, exist_ok=True)

    classes = []
    for item in items:
        document = item.get("labelData") or {}
        annotations = document if isinstance(document, list) else document.get("annotations", [])
        for annotation in annotations:
            base = annotation.get("baseInfo") or {}
            name = str(base.get("cname") or base.get("ename") or "object")
            if name not in classes:
                classes.append(name)
    if not classes:
        raise RuntimeError("标注数据中没有可训练的类别")

    prepared = 0
    for index, item in enumerate(items):
        source = Path(item["imagePath"])
        if not source.is_file():
            continue
        with Image.open(source) as image:
            natural_width, natural_height = image.size
        document = item.get("labelData") or {}
        annotations = document if isinstance(document, list) else document.get("annotations", [])
        image_info = {} if isinstance(document, list) else (document.get("image") or {})
        if not image_info.get("width") or not image_info.get("height"):
            image_info = {"left": 0, "top": 0, "width": natural_width, "height": natural_height}

        label_lines = []
        for annotation in annotations:
            base = annotation.get("baseInfo") or {}
            class_name = str(base.get("cname") or base.get("ename") or "object")
            box = annotation_box(annotation, image_info)
            if box is None:
                continue
            label_lines.append(f"{classes.index(class_name)} " + " ".join(f"{value:.6f}" for value in box))
        if not label_lines:
            continue

        split = "val" if len(items) > 1 and index % 5 == 0 else "train"
        unique_name = f"{item.get('fileId', 'image')}_{item.get('imageIndex', index)}{source.suffix.lower()}"
        target_image = dataset_dir / "images" / split / unique_name
        target_label = dataset_dir / "labels" / split / f"{Path(unique_name).stem}.txt"
        shutil.copy2(source, target_image)
        target_label.write_text("\n".join(label_lines) + "\n", encoding="utf-8")
        prepared += 1

    train_images = list((dataset_dir / "images" / "train").iterdir())
    val_images = list((dataset_dir / "images" / "val").iterdir())
    if not train_images and val_images:
        source = val_images[0]
        shutil.copy2(source, dataset_dir / "images" / "train" / source.name)
        shutil.copy2(dataset_dir / "labels" / "val" / f"{source.stem}.txt", dataset_dir / "labels" / "train" / f"{source.stem}.txt")
    if not val_images and train_images:
        source = train_images[0]
        shutil.copy2(source, dataset_dir / "images" / "val" / source.name)
        shutil.copy2(dataset_dir / "labels" / "train" / f"{source.stem}.txt", dataset_dir / "labels" / "val" / f"{source.stem}.txt")
    if prepared == 0:
        raise RuntimeError("没有可用的矩形、圆形或多边形标注框")

    yaml_path = dataset_dir / "data.yaml"
    names = "\n".join(f"  {i}: {json.dumps(name, ensure_ascii=False)}" for i, name in enumerate(classes))
    yaml_path.write_text(
        f"path: {json.dumps(str(dataset_dir), ensure_ascii=False)}\n"
        "train: images/train\n"
        "val: images/val\n"
        f"nc: {len(classes)}\n"
        f"names:\n{names}\n",
        encoding="utf-8",
    )
    write_status(status_path, status="running", progress=1, message="数据集准备完成，开始训练", classNames=classes, sampleCount=prepared)
    return yaml_path, classes


def metric_value(metrics, key):
    value = metrics.get(key, 0.0) if isinstance(metrics, dict) else 0.0
    try:
        return round(float(value), 6)
    except Exception:
        return 0.0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--job-dir", required=True)
    parser.add_argument("--model", required=True)
    parser.add_argument("--epochs", type=int, required=True)
    parser.add_argument("--batch", type=int, required=True)
    parser.add_argument("--lr", type=float, required=True)
    args = parser.parse_args()

    job_dir = Path(args.job_dir)
    status_path = job_dir / "status.json"
    try:
        import torch
        from ultralytics import YOLO

        yaml_path, classes = prepare_dataset(Path(args.manifest), job_dir, status_path)
        model = YOLO(args.model)

        def update_epoch(trainer):
            epoch = int(trainer.epoch) + 1
            total = int(trainer.epochs)
            losses = trainer.tloss.tolist() if getattr(trainer, "tloss", None) is not None else []
            metrics = getattr(trainer, "metrics", {}) or {}
            write_status(
                status_path,
                status="running",
                currentEpoch=epoch,
                totalEpochs=total,
                progress=max(1, min(99, round(epoch * 100 / total))),
                boxLoss=round(float(losses[0]), 6) if len(losses) > 0 else 0.0,
                clsLoss=round(float(losses[1]), 6) if len(losses) > 1 else 0.0,
                dflLoss=round(float(losses[2]), 6) if len(losses) > 2 else 0.0,
                precision=metric_value(metrics, "metrics/precision(B)"),
                recall=metric_value(metrics, "metrics/recall(B)"),
                map50=metric_value(metrics, "metrics/mAP50(B)"),
                map5095=metric_value(metrics, "metrics/mAP50-95(B)"),
                message=f"正在训练第 {epoch}/{total} 轮",
            )

        model.add_callback("on_fit_epoch_end", update_epoch)
        result = model.train(
            data=str(yaml_path),
            epochs=args.epochs,
            batch=args.batch,
            lr0=args.lr,
            optimizer="AdamW",
            imgsz=640,
            device=0 if torch.cuda.is_available() else "cpu",
            amp=False,
            workers=0,
            project=str(job_dir),
            name="run",
            exist_ok=True,
            verbose=True,
        )
        save_dir = Path(result.save_dir)
        best_source = save_dir / "weights" / "best.pt"
        best_target = job_dir / "best.pt"
        if best_source.is_file():
            shutil.copy2(best_source, best_target)
        write_status(
            status_path,
            status="completed",
            progress=100,
            currentEpoch=args.epochs,
            totalEpochs=args.epochs,
            message="训练完成",
            modelPath=str(best_target if best_target.is_file() else best_source),
            resultDir=str(save_dir),
            classNames=classes,
        )
    except Exception as exc:
        write_status(status_path, status="failed", message=str(exc), error=traceback.format_exc())
        traceback.print_exc()
        raise


if __name__ == "__main__":
    main()
