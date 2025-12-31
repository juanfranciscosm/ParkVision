# ParkVision

![Preview del sistema](results/parking_iou.avi)

Sistema inteligente de monitoreo de estacionamientos basado en **visión por computadora**, diseñado para detectar en tiempo real la ocupación de plazas, registrar sesiones de uso y generar información lista para analítica y dashboards administrativos.

Este repositorio contiene **la fase funcional validada** del proyecto: detección robusta de ocupación, eliminación de falsos positivos y persistencia confiable en base de datos relacional local.

---

## 🎯 Objetivo del proyecto

Desarrollar un sistema que permita:

* Detectar automáticamente plazas de estacionamiento **ocupadas y libres** mediante video.
* Eliminar falsos positivos usando confirmación temporal.
* Registrar **sesiones reales de ocupación** (entrada, salida y duración).
* Persistir los datos en una base de datos relacional.
* Servir como base para futuras extensiones: dashboard web, analítica, reservas y dispositivos IoT.

---

## ✅ Estado actual (funcional y probado)

✔️ Detección de vehículos con modelo YOLO entrenado
✔️ Definición manual de plazas mediante polígonos (`bounding_boxes.json`)
✔️ Cálculo de intersección (IoU) entre vehículo y plaza
✔️ Confirmación temporal por frames (anti-rebotes)
✔️ Eliminación de falsos positivos
✔️ Registro consistente en base de datos SQLite
✔️ Generación de video de salida con visualización de estados

---

## 🧠 Arquitectura actual

```
ParkVision/
│
├── data/
│   ├── database/
│   │   ├── test_parking.db     # Base de datos SQLite (se genera al inciar la base de datos)
│   │   ├── test_schema.sql     # Estructura de la base de datos
|   |   └── test_seed.sql       # Datos iniciales de las plazas del video de prueba
│   └── bounding_boxes.json     # Polígonos de plazas
│
├── src/
│   ├── db/
│   │   ├── init_db.py          # Inicialización de la BD
│   │   └── models.py           # Operaciones CRUD
│   │
│   └── vision/
│       ├── detectionVideoReal.py  # Detección y lógica principal (aqui se procesa video de estacionamiento y actualiza la base de datos)
│       └── boxes.py               # Script para iniciar interfaz gráfica para generar bounding_boxes.json
│
├── media/                       
│   ├── primer_frame.jpg         # Primer frame utilizado para generar datos de las coordenadas de las plazas (bounding_boxes.json) 
│   └── Park_final.mp4           # Video de prueba de estacionamiento  
├── results/                     # Videos procesados (aqui se guarda el video procesado)
├── .venv/                       # Entorno virtual
└── README.md
```

---

## 🗄️ Base de datos (actual)

La base de datos utiliza **SQLite** y contiene las siguientes tablas:

### `estado_actual`

Estado actual de cada plaza.

* `plaza_id`
* `ocupada` (0 / 1)
* `last_update`

### `sesiones`

Historial de ocupación real.

* `id`
* `plaza_id`
* `inicio`
* `fin`
* `duracion_segundos`

👉 Cada sesión corresponde a **una ocupación real**, sin rebotes ni duplicados.

---

## 🎥 Flujo de funcionamiento

1. Se carga el video de entrada.
2. YOLO detecta vehículos en cada frame.
3. Se calcula IoU entre cada vehículo y cada plaza.
4. Se aplica confirmación temporal:
   * `FRAMES_OCUPADO` para marcar ocupada.
   * `FRAMES_LIBRE` para marcar libre.
5. Solo cuando el estado se **confirma**, se actualiza la base de datos.
6. Se dibuja el estado de cada plaza en el video de salida.

---

## ▶️ Ejecución

🛠️ Uso del proyecto (para quien clone el repositorio)

Este proyecto utiliza uv como gestor de entorno y dependencias.
El entorno virtual no se versiona, por lo que cada usuario debe crearlo localmente.

#### 🧩 Requisitos previos
* Python 3.11
* Git
* uv instalado

## Instalar uv (una sola vez):
```powershell
pip install uv
```

### 1. Activar entorno virtual

```powershell
git clone <URL_DEL_REPOSITORIO>
cd ParkVision
```

### 2. Crear el entorno virtual con uv

```powershell
uv venv
```

### 3. Activar entorno virtual

```powershell
.\.venv\Scripts\Activate.ps1
```
Si PowerShell bloquea scripts, ejecutar una sola vez:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### 4. Inicializar base de datos

```powershell
uv run ./src/db/init_db.py
```

### 3. Ejecutar detección 

```powershell
python -m src.vision.detectionVideoReal
```

⚠️ **No ejecutar como script suelto**, siempre como módulo (`-m`).

---

## 📈 Salidas generadas

* 🎥 Video procesado con plazas coloreadas:
  * Verde → libre
  * Rojo → ocupada
* 🗄️ Base de datos actualizada en tiempo real
* 📊 Sesiones listas para analítica

---

## 🧪 Validación

El sistema fue validado comprobando que:

* No se generan múltiples sesiones por una misma ocupación.
* No hay cambios de estado por ruido de uno o pocos frames.
* Las sesiones reflejan tiempos reales de permanencia.

---

## 🔜 Próximas extensiones (no implementadas aún)

* Estados avanzados (`RESERVADO`)
* Sistema de reservas con QR
* API REST (FastAPI)
* Dashboard web en tiempo real
* Integración con ESP32 (LEDs / señalización)
* Analítica avanzada y mapas de calor

---

## 👨‍💻 Autor

Proyecto desarrollado como sistema académico y base para expansión a solución inteligente de estacionamientos.

---

## 📌 Nota

Este README documenta **únicamente lo que ya está implementado y probado**. Las futuras extensiones se desarrollarán sobre esta base estable.
