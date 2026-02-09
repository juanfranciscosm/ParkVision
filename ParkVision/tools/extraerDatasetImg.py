import cv2
from pathlib import Path

video_path = Path("media/PARK_ESPOL.mp4")
interval_seconds = 10

output_dir = Path("frames")
output_dir.mkdir(parents=True, exist_ok=True)

cap = cv2.VideoCapture(str(video_path))
if not cap.isOpened():
    raise FileNotFoundError(f"No se pudo abrir el video: {video_path}")

# Duración del video en ms (puede fallar en algunos códecs, pero suele funcionar)
fps = cap.get(cv2.CAP_PROP_FPS)
frame_count = cap.get(cv2.CAP_PROP_FRAME_COUNT)

if fps and frame_count:
    duration_ms = int((frame_count / fps) * 1000)
else:
    # Fallback: si no se puede calcular, igual intentaremos hasta que falle cap.read()
    duration_ms = None

t_ms = 0
saved = 0

while True:
    cap.set(cv2.CAP_PROP_POS_MSEC, t_ms)
    ok, frame = cap.read()
    if not ok:
        break

    out_path = output_dir / f"frame_{t_ms//1000:06d}s.jpg"  # ej: frame_000010s.jpg
    cv2.imwrite(str(out_path), frame)
    print(f"Guardado: {out_path}")
    saved += 1

    t_ms += interval_seconds * 1000

    # Si conocemos duración, salimos cuando la superamos
    if duration_ms is not None and t_ms > duration_ms:
        break

cap.release()
print(f"Total frames guardados: {saved}")
