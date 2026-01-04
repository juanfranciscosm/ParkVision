import cv2
import json
import time
from ultralytics import YOLO
from shapely.geometry import Polygon
import numpy as np
from pathlib import Path

from src.db.models import (
    get_estado,
    update_estado,
    iniciar_sesion,
    cerrar_sesion
)

# ---------------- CONFIGURACIÓN ----------------
VIDEO_PATH = Path("media/Park_final.mp4")
OUTPUT_PATH = Path("results/parking_iou.avi")
MODEL_PATH = Path("modelos/best.pt")
JSON_PATH = Path("data/bounding_boxes.json")

IOU_THRESHOLD = 0.12
FRAMES_OCUPADO = 15
FRAMES_LIBRE = 150
# ----------------------------------------------


def polygon_iou(poly1, poly2):
    if not poly1.intersects(poly2):
        return 0.0
    inter = poly1.intersection(poly2).area
    union = poly1.union(poly2).area
    return inter / union


# ---------------- CARGA DE PLAZAS ----------------
with open(JSON_PATH, "r") as f:
    plazas_json = json.load(f)

plazas = {idx: Polygon(p["points"]) for idx, p in enumerate(plazas_json)}
# ------------------------------------------------


# ---------------- ESTADO INICIAL (DESDE DB) ----------------
estado = {}
for pid in plazas.keys():
    status_db = get_estado(pid)  # FREE / RESERVED / OCCUPIED
    estado[pid] = {
        "ocupado": status_db == "OCCUPIED",
        "frames_ocupado": 0,
        "frames_libre": 0
    }
# -----------------------------------------------------------


# ---------------- MODELO YOLO ----------------
model = YOLO(MODEL_PATH)
# --------------------------------------------


cap = cv2.VideoCapture(VIDEO_PATH)
w, h, fps = (int(cap.get(x)) for x in (
    cv2.CAP_PROP_FRAME_WIDTH,
    cv2.CAP_PROP_FRAME_HEIGHT,
    cv2.CAP_PROP_FPS
))

video_writer = cv2.VideoWriter(
    OUTPUT_PATH,
    cv2.VideoWriter_fourcc(*"mp4v"),
    fps,
    (w, h)
)

total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
frame_idx = 0

print("▶️ Procesando video...")
start_time = time.time()

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    frame_idx += 1
    if frame_idx % 100 == 0:
        print(f"⏳ Frame {frame_idx}/{total_frames}")

    results = model(
        frame,
        conf=0.25,
        iou=0.5,
        classes=[0],
        verbose=False
    )[0]

    vehiculos = []
    for box in results.boxes.xyxy:
        x1, y1, x2, y2 = box.tolist()
        vehiculos.append(
            Polygon([(x1, y1), (x2, y1), (x2, y2), (x1, y2)])
        )

    for pid, plaza_poly in plazas.items():
        ocupado_ahora = any(
            polygon_iou(plaza_poly, veh) >= IOU_THRESHOLD
            for veh in vehiculos
        )

        # -------- LÓGICA TEMPORAL --------
        if ocupado_ahora:
            estado[pid]["frames_ocupado"] += 1
            estado[pid]["frames_libre"] = 0

            if (
                estado[pid]["frames_ocupado"] >= FRAMES_OCUPADO
                and not estado[pid]["ocupado"]
            ):
                estado[pid]["ocupado"] = True
                update_estado(pid, "OCCUPIED")
                iniciar_sesion(pid)
                print(f"🟢 Plaza {pid} OCUPADA (confirmada)")

        else:
            estado[pid]["frames_libre"] += 1
            estado[pid]["frames_ocupado"] = 0

            if (
                estado[pid]["frames_libre"] >= FRAMES_LIBRE
                and estado[pid]["ocupado"]
            ):
                estado[pid]["ocupado"] = False
                update_estado(pid, "FREE")
                cerrar_sesion(pid)
                print(f"🔵 Plaza {pid} LIBRE (confirmada)")

        # -------- DIBUJO --------
        color = (0, 0, 255) if estado[pid]["ocupado"] else (0, 255, 0)
        pts = np.array(plaza_poly.exterior.coords, dtype=np.int32)
        cv2.polylines(frame, [pts], True, color, 2)

        cx, cy = pts.mean(axis=0).astype(int)
        cv2.putText(
            frame,
            f"{pid}",
            (cx - 10, cy),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.5,
            color,
            1
        )

    video_writer.write(frame)

cap.release()
video_writer.release()

elapsed = time.time() - start_time
print("✅ Procesamiento terminado")
print(f"⏱️ Tiempo total: {elapsed:.2f} segundos")
print(f"🎥 Video guardado en: {OUTPUT_PATH}")
