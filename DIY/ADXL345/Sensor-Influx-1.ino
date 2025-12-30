// GND <=> GND
// VCC <=> 3V3
// D1  <=> SCL
// D2  <=> SCA

#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_ADXL345_U.h>
/* add "ESP8266 Influxdb" by Tobias Schürig using "Library Management" */
#include <InfluxDbClient.h>
/* WIFI */
#include <ESP8266WiFi.h>

// ---------- WiFi ----------
#define WIFI_SSID       "<SSID>"
#define WIFI_PASSWORD   "<Wifi-Password>"

// ---------- InfluxDB v2 ----------
#define INFLUXDB_URL    "http://<Influx-IP>>:8086"   // or http://ip:8086
#define INFLUXDB_ORG    "<ORG>"
#define INFLUXDB_BUCKET "ADXL345-Test"
#define INFLUXDB_TOKEN  "<Token>>"

// Optional: timezone for NTP time sync (Central Europe example)
#define TZ_INFO "CET-1CEST,M3.5.0/1,M10.5.0/3"

// ---------- how many samples to aggregate----------
const uint8_t SAMPLES    = 20;
const uint8_t TOTALDELAY = 200;
uint8_t       LOOPDELAY  = TOTALDELAY / SAMPLES;


// ---------- A V E R A G E  V A L U E S ----------
const float avgX =  0.12f;
const float avgY = -9.96f;
const float avgZ =  1.08f;

// ---------- P R E P A R E ----------
// Create InfluxDB client (for InfluxDB Cloud use InfluxDbCloud2CACert)
InfluxDBClient client(INFLUXDB_URL, INFLUXDB_ORG,
                      INFLUXDB_BUCKET, INFLUXDB_TOKEN);

// Define a point for ADXL345 measurement
Point accelPoint("adxl345");

/* Assign a unique ID to this sensor at the same time */
Adafruit_ADXL345_Unified accel = Adafruit_ADXL345_Unified(12345);

void displaySensorDetails(void)
{
  sensor_t sensor;
  accel.getSensor(&sensor);
  Serial.println("------------------------------------");
  Serial.print  ("Sensor:        "); Serial.println(sensor.name);
  Serial.print  ("Driver Ver:    "); Serial.println(sensor.version);
  Serial.print  ("Unique ID:     "); Serial.println(sensor.sensor_id);
  Serial.print  ("Max Value:     "); Serial.print(sensor.max_value); Serial.println(" m/s^2");
  Serial.print  ("Min Value:     "); Serial.print(sensor.min_value); Serial.println(" m/s^2");
  Serial.print  ("Resolution:    "); Serial.print(sensor.resolution); Serial.println(" m/s^2");  
  Serial.println("------------------------------------");
  Serial.print  ("Influx-Host:   "); Serial.println(INFLUXDB_URL);
  Serial.print  ("Influx-Bucket; "); Serial.println(INFLUXDB_BUCKET);
  Serial.print  ("# Samples:     "); Serial.println(SAMPLES);
  Serial.print  ("Loop Delay:    "); Serial.print(LOOPDELAY); Serial.println(" ms");
  Serial.println("------------------------------------");
  Serial.println("");
  delay(500);
}

void displayDataRate(void)
{
  Serial.print  ("Data Rate:    "); 
  
  switch(accel.getDataRate())
  {
    case ADXL345_DATARATE_3200_HZ:
      Serial.print  ("3200 "); 
      break;
    case ADXL345_DATARATE_1600_HZ:
      Serial.print  ("1600 "); 
      break;
    case ADXL345_DATARATE_800_HZ:
      Serial.print  ("800 "); 
      break;
    case ADXL345_DATARATE_400_HZ:
      Serial.print  ("400 "); 
      break;
    case ADXL345_DATARATE_200_HZ:
      Serial.print  ("200 "); 
      break;
    case ADXL345_DATARATE_100_HZ:
      Serial.print  ("100 "); 
      break;
    case ADXL345_DATARATE_50_HZ:
      Serial.print  ("50 "); 
      break;
    case ADXL345_DATARATE_25_HZ:
      Serial.print  ("25 "); 
      break;
    case ADXL345_DATARATE_12_5_HZ:
      Serial.print  ("12.5 "); 
      break;
    case ADXL345_DATARATE_6_25HZ:
      Serial.print  ("6.25 "); 
      break;
    case ADXL345_DATARATE_3_13_HZ:
      Serial.print  ("3.13 "); 
      break;
    case ADXL345_DATARATE_1_56_HZ:
      Serial.print  ("1.56 "); 
      break;
    case ADXL345_DATARATE_0_78_HZ:
      Serial.print  ("0.78 "); 
      break;
    case ADXL345_DATARATE_0_39_HZ:
      Serial.print  ("0.39 "); 
      break;
    case ADXL345_DATARATE_0_20_HZ:
      Serial.print  ("0.20 "); 
      break;
    case ADXL345_DATARATE_0_10_HZ:
      Serial.print  ("0.10 "); 
      break;
    default:
      Serial.print  ("???? "); 
      break;
  }  
  Serial.println(" Hz");  
}

void displayRange(void)
{
  Serial.print  ("Range:         +/- "); 
  
  switch(accel.getRange())
  {
    case ADXL345_RANGE_16_G:
      Serial.print  ("16 "); 
      break;
    case ADXL345_RANGE_8_G:
      Serial.print  ("8 "); 
      break;
    case ADXL345_RANGE_4_G:
      Serial.print  ("4 "); 
      break;
    case ADXL345_RANGE_2_G:
      Serial.print  ("2 "); 
      break;
    default:
      Serial.print  ("?? "); 
      break;
  }  
  Serial.println(" g");  
}

void setup(void) 
{
#ifndef ESP8266
  while (!Serial); // for Leonardo/Micro/Zero
#endif
  Serial.begin(9600);
  Serial.println("Accelerometer Test"); Serial.println("");
  
  /* Initialise the sensor */
  if(!accel.begin())
  {
    /* There was a problem detecting the ADXL345 ... check your connections */
    Serial.println("Ooops, no ADXL345 detected ... Check your wiring!");
    while(1);
  }

  /* Set the range to whatever is appropriate for your project */
  // accel.setRange(ADXL345_RANGE_16_G);
  // accel.setRange(ADXL345_RANGE_8_G);
  // accel.setRange(ADXL345_RANGE_4_G);
  accel.setRange(ADXL345_RANGE_2_G);
  
  /* Display some basic information on this sensor */
  displaySensorDetails();
  
  /* Display additional settings (outside the scope of sensor_t) */
  displayDataRate();
  displayRange();
  Serial.println("");

  // ----- WiFi connect -----
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED) 
  {
    Serial.print(".");
    delay(500);
  }
  Serial.print(".. connected to ");Serial.print(WIFI_SSID); Serial.print(" using IP: ");  Serial.println(WiFi.localIP());
  Serial.println("");

  // ----- Time sync (needed for InfluxDB v2 TLS + timestamps) -----
  // If you use InfluxDB Cloud / HTTPS you should sync time:
  //timeSync(TZ_INFO, "pool.ntp.org", "time.nis.gov");

  // ----- InfluxDB client check -----
  if (client.validateConnection()) 
  {
    Serial.print("Connected to InfluxDB: ");
    Serial.println(client.getServerUrl());
  } 
  else 
  {
    Serial.print("InfluxDB connection failed: ");
    Serial.println(client.getLastErrorMessage());
  }

  // Set constant tags
  accelPoint.addTag("device", "ESP8266");
  accelPoint.addTag("sensor", "ADXL345");
}

//
// ---------- R U N ----------
//

void loop(void) 
{

  float mdX   = 0.0f;
  float mdY   = 0.0f;
  float mdZ   = 0.0f;
  float mX    = 0.0f;
  float mY    = 0.0f;
  float mZ    = 0.0f;
  float dXmax = 0.0f;
  float dYmax = 0.0f;
  float dZmax = 0.0f;
  float aXmax = 0.0f;
  float aYmax = 0.0f;
  float aZmax = 0.0f;
  
  // collect SAMPLES values at LOOPDELAY Hz
  for (uint8_t i = 0; i < SAMPLES; i++) 
  {
    sensors_event_t event;
    accel.getEvent(&event);

    float aX = event.acceleration.x;   // get actual value
    float aY = event.acceleration.y;   // get actual value
    float aZ = event.acceleration.z;   // get actual value

    float dX = (avgX - aX);
    float dY = (avgY - aY);
    float dZ = (avgZ - aZ);
    
    // Display the single results (acceleration is measured in m/s^2) 
//    Serial.print("X:  "); Serial.print(aX); Serial.print("  ");
//    Serial.print("Y:  "); Serial.print(aY); Serial.print("  ");
//    Serial.print("Z:  "); Serial.print(aZ); Serial.print("  ");
//    Serial.print("dX: "); Serial.print(dX); Serial.print("  ");
//    Serial.print("dY: "); Serial.print(dY); Serial.print("  ");
//    Serial.print("zZ: "); Serial.print(dZ); Serial.print("  ");
//    Serial.println("m/s^2 ");

    // calculate average & max values
    mdX += dX;
    mdY += dY;
    mdZ += dZ;
    mX  += aX;
    mY  += aY;
    mZ  += aZ;

    if (fabs(dX) > fabs(dXmax))
    { dXmax = dX; }
    if (fabs(dY) > fabs(dYmax))
    { dYmax = dY; }
    if (fabs(dZ) > fabs(dZmax))
    { dZmax = dZ; }
    if (fabs(aX) > fabs(aXmax))
    { aXmax = aX; }
    if (fabs(aY) > fabs(aYmax))
    { aYmax = aY; }
    if (fabs(aZ) > fabs(aZmax))
    { aZmax = aZ; }
    
    delay(LOOPDELAY); // 100 Hz sampling
  }

  float dX = mdX / SAMPLES;
  float dY = mdY / SAMPLES;
  float dZ = mdZ / SAMPLES;

  mX = mX / SAMPLES;
  mY = mY / SAMPLES;
  mZ = mZ / SAMPLES;
  
  // Clear previous field values
  accelPoint.clearFields();

  // Add fields: biggest absolute value over last SAMPLES samples
  accelPoint.addField("x", mX);
  accelPoint.addField("y", mY);
  accelPoint.addField("z", mZ);

  accelPoint.addField("dx", dX);
  accelPoint.addField("dy", dY);
  accelPoint.addField("dz", dZ);

  accelPoint.addField("dXmax", dXmax);
  accelPoint.addField("dYmax", dYmax);
  accelPoint.addField("dZmax", dZmax);

  accelPoint.addField("aXmax", aXmax);
  accelPoint.addField("aYmax", aYmax);
  accelPoint.addField("aZmax", aZmax);

  // Display the results (acceleration is measured in m/s^2) 
//  Serial.print("dXmax: "); Serial.print(dXmax); Serial.print("  ");
//  Serial.print("dYmax: "); Serial.print(dYmax); Serial.print("  ");
//  Serial.print("dZmax: "); Serial.print(dZmax); Serial.print("  ");Serial.println("m/s^2 ");

  // Write point (now once per SAMPLES samples)
  if (!client.writePoint(accelPoint)) 
  {     
    Serial.print("InfluxDB write failed: ");
    Serial.println(client.getLastErrorMessage());
  }

  // no extra delay here; loop duration ≈ 20 * 10 ms = 200 ms → 5 writes/sec
}
