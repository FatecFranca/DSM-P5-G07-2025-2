#include <WiFi.h>
#include <HTTPClient.h>
#include "MAX30105.h"
#include "heartRate.h"
#include <TinyGPS++.h>
#include <MPU6050_tockn.h>
#include <Wire.h>
#include <WiFiManager.h>

WiFiManager wm;

#define RED_PIN 13
#define GREEN_PIN 12
#define BLUE_PIN 11

const char* serverName = "https://petdex-api-d75e.onrender.com";
const String coleiraId = "6819475baa479949daccea94";
const String animalId = "68194120636f719fcd5ee5fd";

MAX30105 particleSensor;

const long gmtOffset_sec = -3 * 3600;  // UTC-3 para horário de Brasília
const int daylightOffset_sec = 0;      // Sem horário de verão


const byte RATE_SIZE = 4;  //Increase this for more averaging. 4 is good.
byte rates[RATE_SIZE];     //Array of heart rates
byte rateSpot = 0;
long lastBeat = 0;  //Time at which the last beat occurred

float beatsPerMinute;
int beatAvg;
unsigned long leituraInicio = 0;
const unsigned long duracaoLeitura = 15000;
bool lendo = false;



// -------------- SENSOR DE GPS --------------

#define RXD2 5  // CONECTAR PORTA TX DO SENSOR
#define TXD2 6  // CONECTAR PORTA RX DO SENSOR

#define GPS_BAUD 9600
TinyGPSPlus gps;
// Create an instance of the HardwareSerial class for Serial 2
HardwareSerial gpsSerial(2);

// -------------- // --------------



// -------------- GIROSCÓPIO --------------
MPU6050 mpu6050(Wire);
// -------------- // --------------



void setup() {
  pinMode(RED_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(BLUE_PIN, OUTPUT);
  Serial.begin(115200);
  delay(1000);

  wm.resetSettings();
  // ------------- WIFI -------------
  while (WiFi.status() != WL_CONNECTED) {
    digitalWrite(BLUE_PIN, HIGH);
    Serial.println("Configurar Wifi! Acesse a rede PetDex com a senha petdex1234 e selecione um Wifi para conexão.");
    wm.autoConnect("PetDex", "petdex1234");

    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("Conectado com sucesso!");
    } else {
      Serial.println("Falha ao reconectar.");
    }
  }
  digitalWrite(BLUE_PIN, LOW);
  // -------------- // --------------


  // ------------- HORÁRIO ------------
  configTime(gmtOffset_sec, daylightOffset_sec, "pool.ntp.org");
  delay(2000);  // Espera a sincronização NTP

  struct tm timeinfo;
  while (!getLocalTime(&timeinfo)) {
    Serial.println("Erro ao obter hora");
    digitalWrite(RED_PIN, HIGH);
    digitalWrite(BLUE_PIN, HIGH);
    digitalWrite(GREEN_PIN, HIGH);
  }

  digitalWrite(RED_PIN, LOW);
  digitalWrite(BLUE_PIN, LOW);
  digitalWrite(GREEN_PIN, LOW);

  char isoTime[30];
  strftime(isoTime, sizeof(isoTime), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  Serial.println("Hora atual:");
  Serial.println(isoTime);
  // -------------- // --------------




  // ------------- BATIMENTO CARDÍACO  ------------
  while (!particleSensor.begin(Wire, I2C_SPEED_FAST)) {
    digitalWrite(RED_PIN, HIGH);
    Serial.println("MAX30105 (Batimento Cardíaco) Não foi encontrado. ");
  }
  digitalWrite(RED_PIN, LOW);

  // Ligando as luzes do Batimetno Cardíaco para ajudar a medir
  particleSensor.setup();                     //Configure sensor with default settings
  particleSensor.setPulseAmplitudeRed(0x0A);  //Turn Red LED to low to indicate sensor is running
  particleSensor.setPulseAmplitudeGreen(0);   //Turn off Green LED
  // -------------- // --------------


  // -------------- GPS --------------
  gpsSerial.begin(GPS_BAUD, SERIAL_8N1, RXD2, TXD2);
  // -------------- // --------------




  // -------------- GIROSCÓPIO --------------
  Wire.begin();
  mpu6050.begin();
  mpu6050.calcGyroOffsets(true);
  // -------------- // --------------
}

void loop() {
  digitalWrite(GREEN_PIN, LOW);
  digitalWrite(BLUE_PIN, LOW);
  digitalWrite(RED_PIN, LOW);

  while (WiFi.status() != WL_CONNECTED) {
    digitalWrite(BLUE_PIN, HIGH);
    Serial.println("WiFi desconectado. Tentando reconectar...");
    wm.autoConnect("PetDex", "petdex1234");

    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("Reconectado com sucesso!");
    } else {
      Serial.println("Falha ao reconectar.");
    }
  }

  digitalWrite(BLUE_PIN, LOW);

  double accX;
  double accY;
  double accZ;
  double angleX;
  double angleY;
  double angleZ;

  double latitude;
  double longitude;

  long leituraControle = 0;

  if (!lendo) {
    // Iniciar novo ciclo de leitura
    Serial.println("Iniciando leitura de batimentos por 10 segundos...");
    leituraInicio = millis();
    leituraControle = leituraInicio;
    lendo = true;
    beatAvg = 0;
    rateSpot = 0;
    lastBeat = 0;
    beatsPerMinute = 0;
  }

  // Enquanto estiver dentro do período de leitura
  while (millis() - leituraInicio <= duracaoLeitura) {
    long irValue = particleSensor.getIR();

    if (checkForBeat(irValue)) {
      long delta = millis() - lastBeat;
      lastBeat = millis();

      beatsPerMinute = 60 / (delta / 1000.0);

      if (beatsPerMinute < 255 && beatsPerMinute > 20) {
        rates[rateSpot++] = (byte)beatsPerMinute;
        rateSpot %= RATE_SIZE;

        beatAvg = 0;
        for (byte x = 0; x < RATE_SIZE; x++)
          beatAvg += rates[x];
        beatAvg /= RATE_SIZE;
      }
    }

    Serial.print("IR=");
    Serial.print(irValue);
    Serial.print(", BPM=");
    Serial.print(beatsPerMinute);
    Serial.print(", Avg BPM=");
    Serial.print(beatAvg);
    if (irValue < 50000 && millis() - leituraControle <= 20000) {
      // Espera até 20 segundos para o usuário colocar o dedo para realizar a leitura
      leituraInicio = millis();
      Serial.print(" Não está medindo batimentos");
    }
    Serial.println();
  }

  lendo = false;

  unsigned long start = millis();
  while (millis() - start < 1000) {
    while (gpsSerial.available() > 0) {
      gps.encode(gpsSerial.read());
    }
    if (gps.location.isUpdated()) {
      latitude = gps.location.lat();
      longitude = gps.location.lng();
    }
  }

  // -------------- GIROSCÓPIO --------------
  mpu6050.update();

  accX = mpu6050.getAccX();
  accY = mpu6050.getAccY();
  accZ = mpu6050.getAccZ();

  angleX = mpu6050.getGyroAngleX();
  angleY = mpu6050.getGyroAngleY();
  angleZ = mpu6050.getGyroAngleZ();

  // -------------- // --------------

  String timestamp = getISO8601Time();
  Serial.println("\n---------------------- LOCALIZACAO ----------------------");
  Serial.print("Latitude: ");
  Serial.print(latitude);
  Serial.print("  Longitude: ");
  Serial.println(longitude);
  Serial.println("\n-----------------------------------------------------------");
  if (beatAvg > 5) {
    enviarBatimento(beatAvg, timestamp);
  }
  if (((latitude > 1 && longitude > 1) || (latitude < -1 && longitude < -1)) && (latitude != 23.594131 && longitude != 23.93906)) {
    enviarLocalizacao(latitude, longitude, timestamp);
  }
  enviarMovimento(accX, accY, accZ, angleX, angleY, angleZ, timestamp);
}



String getISO8601Time() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Erro ao obter hora");
    return "";
  }

  char isoTime[30];
  strftime(isoTime, sizeof(isoTime), "%Y-%m-%dT%H:%M:%S-03:00", &timeinfo);
  return String(isoTime);
}

void enviarBatimento(int media, String timestamp) {
  digitalWrite(GREEN_PIN, HIGH);
  digitalWrite(RED_PIN, LOW);
  digitalWrite(BLUE_PIN, LOW);
  String endpoint = String(serverName) + "/batimentos";
  HTTPClient http;
  String jsonData = "{";
  jsonData += "\"frequenciaMedia\": \"" + String(media) + "\", ";
  jsonData += "\"coleira\": \"" + coleiraId + "\", ";
  jsonData += "\"animal\": \"" + animalId + "\", ";
  jsonData += "\"data\": \"" + timestamp + "\"";
  jsonData += "}";

  Serial.println("Enviando Batimento:");
  Serial.println(jsonData);
  http.begin(endpoint);
  http.addHeader("Content-Type", "application/json");
  int httpResponseCode = http.POST(jsonData);
  Serial.print("POST status: ");
  Serial.println(httpResponseCode);
  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.println("Resposta: " + response);
  } else {
    digitalWrite(RED_PIN, HIGH);
    Serial.println("Erro ao enviar dados.");
    delay(500);
  }

  http.end();
}

void enviarLocalizacao(double latitude, double longitude, String timestamp) {
  digitalWrite(GREEN_PIN, HIGH);
  digitalWrite(RED_PIN, LOW);
  digitalWrite(BLUE_PIN, LOW);
  String endpoint = String(serverName) + "/localizacoes";
  HTTPClient http;
  String jsonData = "{";
  jsonData += "\"latitude\": \"" + String(latitude, 6) + "\", ";
  jsonData += "\"longitude\": \"" + String(longitude, 6) + "\", ";
  jsonData += "\"coleira\": \"" + coleiraId + "\", ";
  jsonData += "\"animal\": \"" + animalId + "\", ";
  jsonData += "\"data\": \"" + timestamp + "\"";
  jsonData += "}";

  Serial.println("Enviando Localização:");
  Serial.println(jsonData);
  http.begin(endpoint);
  http.addHeader("Content-Type", "application/json");
  int httpResponseCode = http.POST(jsonData);
  Serial.print("POST status: ");
  Serial.println(httpResponseCode);
  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.println("Resposta: " + response);
  } else {
    Serial.println("Erro ao enviar dados.");
    digitalWrite(RED_PIN, HIGH);
    Serial.println("Erro ao enviar dados.");
    delay(500);
  }

  http.end();
}

void enviarMovimento(double accX, double accY, double accZ, double angleX, double angleY, double angleZ, String timestamp) {
  digitalWrite(GREEN_PIN, HIGH);
  digitalWrite(RED_PIN, LOW);
  digitalWrite(BLUE_PIN, LOW);
  String endpoint = String(serverName) + "/movimentos";
  HTTPClient http;
  String jsonData = "{";
  jsonData += "\"acelerometroX\": \"" + String(accX) + "\", ";
  jsonData += "\"acelerometroY\": \"" + String(accY) + "\", ";
  jsonData += "\"acelerometroZ\": \"" + String(accZ) + "\", ";
  jsonData += "\"giroscopioX\": \"" + String(angleX) + "\", ";
  jsonData += "\"giroscopioY\": \"" + String(angleY) + "\", ";
  jsonData += "\"giroscopioZ\": \"" + String(angleZ) + "\", ";
  jsonData += "\"coleira\": \"" + coleiraId + "\", ";
  jsonData += "\"animal\": \"" + animalId + "\", ";
  jsonData += "\"data\": \"" + timestamp + "\"";
  jsonData += "}";

  Serial.println("Enviando Movimento:");
  Serial.println(jsonData);
  http.begin(endpoint);
  http.addHeader("Content-Type", "application/json");
  int httpResponseCode = http.POST(jsonData);
  Serial.print("POST status: ");
  Serial.println(httpResponseCode);
  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.println("Resposta: " + response);
  } else {
    Serial.println("Erro ao enviar dados.");
    digitalWrite(RED_PIN, HIGH);
    Serial.println("Erro ao enviar dados.");
    delay(500);
  }

  http.end();
}