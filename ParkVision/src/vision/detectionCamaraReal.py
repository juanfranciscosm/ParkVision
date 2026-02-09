import cv2
import json
import time
from ultralytics import YOLO
from shapely.geometry import Polygon
import numpy as np
from pathlib import Path

from src.real_db.models import (
    get_estado,
    update_estado,
    iniciar_sesion,
    cerrar_sesion
)

# ---------------- CONFIGURACIÓN ----------------
OUTPUT_PATH = Path("results/parking_iou.avi")
MODEL_PATH = Path("modelos/MaquetaParkingTrained.pt")
JSON_PATH = Path("data/bounding_boxes.json")

IOU_THRESHOLD = 0.12
FRAMES_OCUPADO = 15
FRAMES_LIBRE = 15

CAM_INDEX = 1  
SHOW_WINDOW = True
WINDOW_NAME = "ParkVision - Debug (q=salir, p=pausa)"
DRAW_VEHICLES = True  # dibuja cajas detectadas
# ----------------------------------------------


def polygon_iou(poly1, poly2):
    if not poly1.intersects(poly2):
        return 0.0
    inter = poly1.intersection(poly2).area
    union = poly1.union(poly2).area
    return inter / union


def draw_overlay_panel(frame, lines, x=10, y=10):
    """
    Dibuja un panel con fondo para texto.
    lines: lista de strings.
    """
    font = cv2.FONT_HERSHEY_SIMPLEX
    scale = 0.6
    thickness = 2
    line_h = 22
    padding = 10

    # calcula ancho máximo
    widths = [cv2.getTextSize(t, font, scale, thickness)[0][0] for t in lines]
    panel_w = (max(widths) if widths else 0) + padding * 2
    panel_h = len(lines) * line_h + padding * 2

    # fondo (rectángulo semi opaco)
    overlay = frame.copy()
    cv2.rectangle(overlay, (x, y), (x + panel_w, y + panel_h), (0, 0, 0), -1)
    alpha = 0.45
    cv2.addWeighted(overlay, alpha, frame, 1 - alpha, 0, frame)

    # texto
    ty = y + padding + 16
    for t in lines:
        cv2.putText(frame, t, (x + padding, ty), font, scale, (255, 255, 255), thickness, cv2.LINE_AA)
        ty += line_h


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


cap = cv2.VideoCapture(CAM_INDEX)
if not cap.isOpened():
    raise RuntimeError(f"No se pudo abrir la cámara con índice {CAM_INDEX}")

w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH)) or 1280
h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT)) or 720
fps = cap.get(cv2.CAP_PROP_FPS)
fps = int(fps) if fps and fps > 0 else 30

video_writer = cv2.VideoWriter(
    str(OUTPUT_PATH),
    cv2.VideoWriter_fourcc(*"mp4v"),
    fps,
    (w, h)
)

print("▶️ Detección en tiempo real iniciada (solo imprime cambios confirmados).")
print("   Controles: q = salir | p = pausar/reanudar")
start_time = time.time()

paused = False

while cap.isOpened():
    if not paused:
        ret, frame = cap.read()
        if not ret:
            break

        # --- YOLO ---
        results = model(
            frame,
            conf=0.9,
            iou=0.5,
            classes=[0],
            verbose=False
        )[0]

        # --- Vehículos detectados como polígonos (bbox) ---
        vehiculos = []
        car_count = 0

        if results.boxes is not None and len(results.boxes) > 0:
            car_count = len(results.boxes)
            for box in results.boxes.xyxy:
                x1, y1, x2, y2 = box.tolist()
                vehiculos.append(
                    Polygon([(x1, y1), (x2, y1), (x2, y2), (x1, y2)])
                )

                if DRAW_VEHICLES:
                    cv2.rectangle(frame, (int(x1), int(y1)), (int(x2), int(y2)), (255, 255, 255), 2)
                    cv2.putText(
                        frame, "car",
                        (int(x1), max(int(y1) - 5, 0)),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5,
                        (255, 255, 255), 1
                    )

        # --- Evaluación por plaza ---
        for pid, plaza_poly in plazas.items():
            ocupado_ahora = any(
                polygon_iou(plaza_poly, veh) >= IOU_THRESHOLD
                for veh in vehiculos
            )

            # -------- LÓGICA TEMPORAL (solo imprime cuando cambia confirmado) --------
            if ocupado_ahora:
                estado[pid]["frames_ocupado"] += 1
                estado[pid]["frames_libre"] = 0

                if estado[pid]["frames_ocupado"] >= FRAMES_OCUPADO and not estado[pid]["ocupado"]:
                    estado[pid]["ocupado"] = True
                    update_estado(pid, "OCCUPIED")
                    iniciar_sesion(pid)
                    print(f"🟥 Plaza {pid} -> OCCUPIED (confirmada)")

            else:
                estado[pid]["frames_libre"] += 1
                estado[pid]["frames_ocupado"] = 0

                if estado[pid]["frames_libre"] >= FRAMES_LIBRE and estado[pid]["ocupado"]:
                    estado[pid]["ocupado"] = False
                    update_estado(pid, "FREE")
                    cerrar_sesion(pid)
                    print(f"🟩 Plaza {pid} -> FREE (confirmada)")

            # -------- DIBUJO ROI + ID --------
            color = (0, 0, 255) if estado[pid]["ocupado"] else (0, 255, 0)

            pts = np.array(plaza_poly.exterior.coords, dtype=np.int32)
            cv2.polylines(frame, [pts], True, color, 2)

            cx, cy = pts.mean(axis=0).astype(int)
            cv2.putText(
                frame,
                f"{pid}",
                (cx - 10, cy),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.6,
                color,
                2
            )

        # --- Conteos para overlay ---
        total_plazas = len(plazas)
        ocupados = sum(1 for pid in plazas.keys() if estado[pid]["ocupado"])
        libres = total_plazas - ocupados

        # --- Panel de info en pantalla ---
        lines = [
            f"Disponibles: {libres}",
            f"Ocupados: {ocupados}",
            f"Carros detectados: {car_count}",
        ]
        draw_overlay_panel(frame, lines, x=10, y=10)

        # --- Guardar video debug (opcional) ---
        video_writer.write(frame)

    # --- Mostrar ventana siempre (incluso pausado) ---
    if SHOW_WINDOW and "frame" in locals():
        cv2.imshow(WINDOW_NAME, frame)

    key = cv2.waitKey(1) & 0xFF
    if key == ord("q"):
        break
    if key == ord("p"):
        paused = not paused
        print("⏸️ Pausado" if paused else "▶️ Reanudado")

cap.release()
video_writer.release()
cv2.destroyAllWindows()

elapsed = time.time() - start_time
print("✅ Detección terminada")
print(f"⏱️ Tiempo total: {elapsed:.2f} s")
print(f"🎥 Video guardado en: {OUTPUT_PATH}")
