#include <WiFi.h>
#include <PubSubClient.h>

int hallPin = 3;
//For Wifi Setup
const char* ssid = "yourWifiSSID";
const char* password = "yourWifiPassword";

//For MQTT Broker
const char* mqtt_server = "yourMQTTserver";
const int mqtt_port = 1883;
const char* mqtt_topic = "yourTopic";
char* message = "Intruder Detected";

//Bootstrap Authroization Login
const char* mqtt_username = "yourMQTTusername";
const char* mqtt_password = "yourMQTTpassword";

String receivedMessage;
bool dangerous = false;
bool old_status = dangerous;
bool can_send = true;

WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  pinMode(hallPin, INPUT);   
  Serial.begin(115200);
  
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
  
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
  
  while (!client.connected()) {
    Serial.println("Connecting to MQTT...");
    if (client.connect("ESP32Client", mqtt_username, mqtt_password))  {
      Serial.println("Connected to MQTT");
      client.subscribe(mqtt_topic);
    } else {
      Serial.print("Failed, rc=");
      Serial.print(client.state());
      Serial.println(" Retrying in 5 seconds...");
      delay(5000);
    }
  }
  client.subscribe("Security");
}

void loop() {

  client.loop();
  if (can_send){
    client.publish(mqtt_topic, message);
    can_send = false;
    Serial.println("Sent");
  }

  if (digitalRead(hallPin) == HIGH){
    dangerous = true;
    update_can_send();
  }
}

void callback(char* topic, byte* payload, unsigned int length) {

  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");

  receivedMessage = "";
  for (int i = 0; i < length; i++) {
    receivedMessage += (char)payload[i];
  }
  Serial.println(receivedMessage);

  if (receivedMessage == "Acknowledged"){
    dangerous = false;
    update_can_send();
  }

}

void update_can_send(){
  if (dangerous != old_status){
    can_send = true;
    old_status = dangerous;
  } else {
    can_send = false;
  }

  if (!dangerous){
    message = "No Threat Currently";
  } else {
    message = "Intruder Detected";
  }
}
