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

# ====================== 配置路径 ======================
model_path = "D:/project3/yolov8n.pt"
watch_dir = "C:/Users/zylmy/Pictures/2026_08_04"
conf_threshold = 0.25

# ========== 结果保存路径 ==========
OUTPUT_FOLDER = "D:/project3/auto-label-detection-platform-main/results"
os.makedirs(OUTPUT_FOLDER, exist_ok=True)
# ==================================

# 全局只加载一次模型
print(f"📁 监听文件夹: {watch_dir}")
print(f"📁 输出文件夹: {OUTPUT_FOLDER}")
print(f"🤖 模型路径: {model_path}")
print("✅ 开始监听（轮询模式，每2秒扫描一次）...\n")

model = YOLO(model_path)


def detect_single_image(img_path: str):
    """检测单张图片，返回检测结果和标注后的图片"""
    image = cv2.imread(img_path)
    if image is None:
        return {"image": os.path.basename(img_path), "detections": []}, None, None

    h, w = image.shape[:2]
    results = model.predict(source=img_path, conf=conf_threshold, verbose=False)

    detections = []
    next_id = 1
    for r in results:
        for box in r.boxes:
            cls_id = int(box.cls[0])
            conf = float(box.conf[0])
            x1, y1, x2, y2 = box.xyxy[0].tolist()

            detections.append({
                "id": next_id,
                "label": r.names[cls_id],
                "confidence": round(conf * 100, 2),
                "x": round(x1 / w * 100, 2),
                "y": round(y1 / h * 100, 2),
                "width": round((x2 - x1) / w * 100, 2),
                "height": round((y2 - y1) / h * 100, 2),
            })
            next_id += 1

    annotated_img = results[0].plot() if results else None
    return {"image": os.path.basename(img_path), "detections": detections}, annotated_img, image


def save_to_results(filename: str, detections: list, annotated_img, original_img):
    """保存检测结果到 results 文件夹"""

    det_img_path = os.path.join(OUTPUT_FOLDER, f"det_{filename}")
    cv2.imwrite(det_img_path, annotated_img)
    print(f"✅ 带框图片已保存: {det_img_path}", file=sys.stderr)

    orig_img_path = os.path.join(OUTPUT_FOLDER, f"orig_{filename}")
    cv2.imwrite(orig_img_path, original_img)
    print(f"✅ 原图已保存: {orig_img_path}", file=sys.stderr)

    json_filename = f"det_{os.path.splitext(filename)[0]}.json"
    output_json_path = os.path.join(OUTPUT_FOLDER, json_filename)

    result_data = {
        "filename": filename,
        "originalImage": f"/results/orig_{filename}",
        "detectedImage": f"/results/det_{filename}",
        "detections": []
    }

    for det in detections:
        x = det.get("x", 0)
        y = det.get("y", 0)
        width = det.get("width", 0)
        height = det.get("height", 0)

        result_data["detections"].append({
            "class": det.get("label", "unknown"),
            "confidence": det.get("confidence", 0) / 100,
            "bbox": [x, y, x + width, y + height]
        })

    with open(output_json_path, 'w', encoding='utf-8') as f:
        json.dump(result_data, f, ensure_ascii=False, indent=2)
    print(f"✅ JSON 已保存: {output_json_path}", file=sys.stderr)


def main():
    processed_files = set()
    scan_interval = 2  # 扫描间隔（秒）

    while True:
        try:
            exts = ('.jpg', '.jpeg', '.png', '.bmp', '.webp')

            # 扫描文件夹
            for filename in os.listdir(watch_dir):
                if not filename.lower().endswith(exts):
                    continue

                file_path = os.path.join(watch_dir, filename)

                # 跳过已处理的文件
                if file_path in processed_files:
                    continue

                # 检查文件是否存在
                if not os.path.exists(file_path):
                    continue

                # 检查文件是否完整（等待写入完成）
                try:
                    size1 = os.path.getsize(file_path)
                    time.sleep(0.3)
                    size2 = os.path.getsize(file_path)
                    if size1 != size2 or size1 == 0:
                        continue  # 文件还在写入或为空
                except:
                    continue

                # 检查是否是图片
                try:
                    img = cv2.imread(file_path)
                    if img is None:
                        continue
                except:
                    continue

                print(f"📷 发现新图片: {filename}", file=sys.stderr)

                # 检测图片
                res, annotated_img, original_img = detect_single_image(file_path)

                # 输出到控制台
                print(json.dumps({"type": "real_time", "data": res}, ensure_ascii=False))
                sys.stdout.flush()

                if annotated_img is not None and original_img is not None:
                    save_to_results(filename, res.get("detections", []), annotated_img, original_img)
                    print(f"✅ 检测完成: {filename}\n", file=sys.stderr)
                else:
                    print(f"❌ 检测失败: {filename}", file=sys.stderr)

                # 标记为已处理
                processed_files.add(file_path)

            time.sleep(scan_interval)

        except KeyboardInterrupt:
            print("\n👋 已退出", file=sys.stderr)
            break
        except Exception as e:
            print(f"❌ 错误: {e}", file=sys.stderr)
            time.sleep(scan_interval)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(json.dumps({"error": str(e)}, ensure_ascii=False), file=sys.stderr)
        sys.exit(1)