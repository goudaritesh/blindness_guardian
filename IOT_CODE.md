# ESP32 IoT Code Migration (Firebase -> Node.js)

Since we switched to a custom Node.js backend, you should use the `HTTPClient` library instead of the Firebase libraries. This is much lighter and more stable for the ESP32.

### 1. Updated ESP32 Logic (Partial Snippet)

```cpp
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// Replace with your Render/Server URL
const char* serverUrl = "https://your-app-name.onrender.com";
const char* deviceId = "STICK_001";

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
}

// Function to send Location to Node.js
void sendLocation(double lat, double lng) {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(String(serverUrl) + "/api/iot/location");
    http.addHeader("Content-Type", "application/json");

    StaticJsonDocument<200> doc;
    doc["deviceId"] = deviceId;
    doc["lat"] = lat;
    doc["lng"] = lng;

    String jsonResponse;
    serializeJson(doc, jsonResponse);

    int httpResponseCode = http.POST(jsonResponse);
    Serial.print("Location Sent. Response: ");
    Serial.println(httpResponseCode);
    http.end();
  }
}

// Function to trigger SOS/Fall Alert
void triggerAlert(String type, double lat, double lng) {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(String(serverUrl) + "/api/iot/alert");
    http.addHeader("Content-Type", "application/json");

    StaticJsonDocument<200> doc;
    doc["deviceId"] = deviceId;
    doc["type"] = type; // "SOS" or "FALL"
    doc["lat"] = lat;
    doc["lng"] = lng;
    doc["imageUrl"] = "https://example.com/live_camera_shot.jpg"; // Optional

    String jsonResponse;
    serializeJson(doc, jsonResponse);

    int httpResponseCode = http.POST(jsonResponse);
    Serial.print("Alert Sent! Type: " + type + " Code: ");
    Serial.println(httpResponseCode);
    http.end();
  }
}

// Function to send Heartbeat (Battery & Signal)
void updateStatus(int battery, int signal) {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(String(serverUrl) + "/api/iot/status");
    http.addHeader("Content-Type", "application/json");

    StaticJsonDocument<200> doc;
    doc["deviceId"] = deviceId;
    doc["battery"] = battery;
    doc["signal"] = signal;

    String jsonResponse;
    serializeJson(doc, jsonResponse);

    int httpResponseCode = http.POST(jsonResponse);
    http.end();
  }
}

void loop() {
  // Example: Send heartbeat every 30 seconds
  updateStatus(85, -60);
  delay(30000);
}
```

### 🔋 Key Advantages of this change:
1. **Lighter Firmware**: No more heavy Firebase libraries using up ESP32 memory.
2. **Speed**: Direct HTTP POST is faster for real-time SOS.
3. **No Setup Fee**: Render + MySQL is free for development.
