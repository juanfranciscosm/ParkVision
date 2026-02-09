import cv2
from pathlib import Path

video_path = Path("../results/espol_parking_iou.avi")
t_seconds = 20

cap = cv2.VideoCapture(video_path)

cap.set(cv2.CAP_PROP_POS_MSEC, t_seconds * 1000)

ok, frame = cap.read()
if ok:
    cv2.imwrite("frame_5_s.jpg", frame)
    print("Guardado: frame_5_2s.jpg")
else:
    print("No se pudo leer el video")

cap.release()
