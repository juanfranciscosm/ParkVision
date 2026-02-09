#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <ESP32Servo.h>

// ==========================================
//   1. CONFIGURACIÓN DE RED
// ==========================================
const char* ssid = "NETLIFE-SANCHEZ";
const char* password = "0931879613";
// RECUERDA: IP de tu PC con el servidor
const char* serverUrl = "http://192.168.100.14:8000/spots"; 

// ==========================================
//   2. CONFIGURACIÓN DE PINES
// ==========================================
#define DATA_PIN  33 
#define LATCH_PIN 32 
#define CLOCK_PIN 25 

#define PIN_SERVO     14
#define TRIG_PIN      26
#define ECHO_PIN      27

// ==========================================
//   3. VARIABLES GLOBALES
// ==========================================
uint16_t maskRojos = 0;
uint16_t maskVerdes = 0;
uint16_t maskReservados = 0;

unsigned long pwmTimer = 0;
uint8_t pwmPhase = 0;

// Ajusta el tono:
// 0..100  (más alto = más rojo, más "amarillo naranja")
const uint8_t AMARILLO_ROJO_PCT = 70;  
// Ej: 50 = amarillo balanceado, 70 = más amarillento (tirando a naranja), 60 = un poco más rojo

unsigned long ultimoCheckAPI = 0;
const long intervaloAPI = 1000; 

Servo barrera;
int anguloCerrado = 0;   
int anguloAbierto = 90;  
int velocidadSuave = 15; 

// --- NUEVA VARIABLE DE CONTROL ---
bool hayEspacio = true; // Por seguridad empieza en true, la API lo corregirá

// ==========================================
//   4. PROTOTIPOS
// ==========================================
void actualizarShiftRegisters(uint16_t rojos, uint16_t verdes);
long leerDistancia();
void moverBarrera(bool abrir);
void esperarAQuePaseElCarro();
void gestionarLucesAPI();
void refrescarLedsPWM();

// ==========================================
//   SETUP
// ==========================================
void setup() {
  Serial.begin(115200);

  // Pines
  pinMode(DATA_PIN, OUTPUT);
  pinMode(LATCH_PIN, OUTPUT);
  pinMode(CLOCK_PIN, OUTPUT);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  // Servo
  barrera.setPeriodHertz(50);
  barrera.attach(PIN_SERVO, 500, 2400);
  barrera.write(anguloCerrado); 

  // WiFi
  WiFi.begin(ssid, password);
  Serial.print("Conectando a WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi Conectado!");
}

// ==========================================
//   LOOP PRINCIPAL
// ==========================================
void loop() {
  // 1. CONTROL DE BARRERA
  long distancia = leerDistancia();
  
  // Si hay carro cerca (8cm)...
  if (distancia > 0 && distancia <= 8) {
    
    // --- AQUÍ ESTÁ LA NUEVA INTELIGENCIA ---
    if (hayEspacio == true) {
        Serial.println(">>> BIENVENIDO: ABRIENDO BARRERA <<<");
        moverBarrera(true); // Abrir
        esperarAQuePaseElCarro(); 
        Serial.println(">>> CERRANDO <<<");
        moverBarrera(false); // Cerrar
    } else {
        // Si NO hay espacio, no hacemos nada, solo avisamos
        Serial.println(">>> ¡ALTO! PARKING LLENO (NO SE ABRE) <<<");
        delay(1000); // Esperar un poco para no saturar el monitor
    }
  }

  // 2. CONTROL DE API
  gestionarLucesAPI(); 
  refrescarLedsPWM();
  
  delay(50); 
}

// ==========================================
//   FUNCIONES
// ==========================================

void moverBarrera(bool abrir) {
  if (abrir) {
    for (int pos = anguloCerrado; pos <= anguloAbierto; pos++) {
      barrera.write(pos);
      delay(velocidadSuave);
    }
  } else {
    for (int pos = anguloAbierto; pos >= anguloCerrado; pos--) {
      barrera.write(pos);
      delay(velocidadSuave);
    }
  }
}

long leerDistancia() {
  digitalWrite(TRIG_PIN, LOW); delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH); delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duracion = pulseIn(ECHO_PIN, HIGH, 25000); 
  if (duracion == 0) return 999; 
  return duracion * 0.034 / 2;
}

void esperarAQuePaseElCarro() {
  unsigned long tiempoSinDeteccion = 0;
  bool carroPareceHaberseIdo = false;

  Serial.println("Esperando que cruce...");

  while (true) {
    long d = leerDistancia();
    if (d > 10 || d == 0) {
      if (!carroPareceHaberseIdo) {
        tiempoSinDeteccion = millis(); 
        carroPareceHaberseIdo = true;
      }
      if (millis() - tiempoSinDeteccion > 1000) {
        break; 
      }
    } else {
      carroPareceHaberseIdo = false;
    }
    gestionarLucesAPI(); 
    delay(50); 
  }
}

void gestionarLucesAPI() {
  if (millis() - ultimoCheckAPI >= intervaloAPI) {
    ultimoCheckAPI = millis();

    if (WiFi.status() == WL_CONNECTED) {
      HTTPClient http;
      http.begin(serverUrl);
      int httpCode = http.GET();

      if (httpCode > 0) {
        String payload = http.getString();
        JsonDocument doc;
        DeserializationError error = deserializeJson(doc, payload);

        if (!error) {
          uint16_t estadoRojos = 0;
          uint16_t estadoVerdes = 0;
          uint16_t estadoReservadosLocal = 0;

          bool encontramosAlMenosUnoLibre = false;

          for (JsonObject spot : doc.as<JsonArray>()) {
            int id = spot["spot_id"];
            const char* status = spot["status"];

            if (id >= 0 && id < 8) {
              if (strcmp(status, "OCCUPIED") == 0) {
                estadoRojos |= (1 << id);
              }
              else if (strcmp(status, "FREE") == 0) {
                estadoVerdes |= (1 << id);
                encontramosAlMenosUnoLibre = true;
              }
              else if (strcmp(status, "RESERVED") == 0) {
                // Reservado: se renderiza como "amarillo" usando PWM por tiempo
                estadoReservadosLocal |= (1 << id);
              }
            }
          }

          hayEspacio = encontramosAlMenosUnoLibre;

          // Guardamos para el "PWM por tiempo"
          maskRojos = estadoRojos;
          maskVerdes = estadoVerdes;
          maskReservados = estadoReservadosLocal;

          // El refresco visual lo hace refrescarLedsPWM() en el loop().
        }
      }

      http.end();
    }
  }
}

void refrescarLedsPWM() {
  // Ciclo PWM de 100 pasos a 200 Hz aprox (ajusta si quieres)
  // Un periodo total = 100 * 2ms = 200ms (5Hz) -> eso parpadearía visible.
  // Mejor: 1ms => 100ms (10Hz) aún visible para algunos.
  // Para que NO se note: 0.2ms no es posible con delay.
  // Entonces usaremos un enfoque: 10 fases, cada 2ms => 20ms (50Hz) no molesta mucho.
  // Mejor aún: 20 fases x 1ms => 20ms (50Hz)

  static const uint8_t PHASES = 20; // 50Hz si cada fase dura 1ms
  static const uint16_t PHASE_MS = 0.5;

  if (millis() - pwmTimer < PHASE_MS) return;
  pwmTimer = millis();

  pwmPhase = (pwmPhase + 1) % PHASES;

  // Convertimos % a fases activas
  uint8_t rojoFases = (AMARILLO_ROJO_PCT * PHASES) / 100;  // ej 70% de 20 => 14 fases
  uint8_t verdeFases = PHASES - rojoFases;                 // 6 fases

  // Para reservados: durante 'rojoFases' mostramos rojo, durante el resto verde
  bool faseRoja = (pwmPhase < rojoFases);

  uint16_t rojosOut = maskRojos;
  uint16_t verdesOut = maskVerdes;

  if (faseRoja) {
    // reservados se ven más rojos
    rojosOut |= maskReservados;
    // verdesOut NO incluye reservados en esta fase
  } else {
    // reservados se ven más verdes
    verdesOut |= maskReservados;
    // rojosOut NO incluye reservados en esta fase
  }

  actualizarShiftRegisters(rojosOut, verdesOut);
}


void actualizarShiftRegisters(uint16_t rojos, uint16_t verdes) {
  digitalWrite(LATCH_PIN, LOW);
  shiftOut(DATA_PIN, CLOCK_PIN, MSBFIRST, lowByte(verdes)); 
  shiftOut(DATA_PIN, CLOCK_PIN, MSBFIRST, lowByte(rojos));  
  digitalWrite(LATCH_PIN, HIGH);
}