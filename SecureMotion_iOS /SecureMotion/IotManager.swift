
import Foundation
import CocoaMQTT

class IoTManager: CocoaMQTTDelegate, ObservableObject{
    
    var mqtt: CocoaMQTT!
    
    @Published var receivedMessage: String = ""
    @Published var isConnected: Bool = false
    
    func connectToIoTDevice() {
        let clientID = "SwiftAPP"
        let serverURL = "yourserver"
        let serverPort: UInt16 = 1883 // or the port specified by your IoT device
        let user = "yourusername"
        let passwd = "yourpassword"

        mqtt = CocoaMQTT(clientID: clientID, host: serverURL, port: serverPort)
        mqtt.username = user
        mqtt.password = passwd
        mqtt.delegate = self
        mqtt.connect()
    }

    func disconnect(){
        mqtt.disconnect()
    }
    
    // MARK: - CocoaMQTTDelegate methods

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            DispatchQueue.main.async {
                self.isConnected = true
            }
            print("Connected to the IoT device!")
            // Perform actions after successful connection
        } else {
            DispatchQueue.main.async {
                self.isConnected = false
            }
            print("Failed to connect to the IoT device")
        }
    }
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("MQTT Did Publish Ack for Message with ID: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Data published successfully")
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        if let messageString = message.string {
            print("Received message on topic \(message.topic): \(messageString)")
            DispatchQueue.main.async {
                self.receivedMessage = messageString
            }
        }
    }
}

extension IoTManager {
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed:[String]) {
            print("MQTT Did Subscribe Topics: Success - \(success), Failed - \(failed)")
    }
        
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("MQTT Did Unsubscribe Topics: \(topics)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("MQTT Did Subscribe to Topic: \(topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("MQTT Did Unsubscribe from Topic: \(topic)")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
        }
        if let error = err {
            print("MQTT Did Disconnect with Error: \(error.localizedDescription)")
        } else {
            print("MQTT Did Disconnect")
        }
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("MQTT Did Ping")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("MQTT Did Receive Pong")
    }
    
    func subscribeToTopic(topic: String) {
        mqtt.subscribe(topic)
    }

    func publishData(topic: String, message: String) {
        mqtt.publish(topic, withString: message, qos: .qos1)
    }

    func mqtt(_ mqtt: CocoaMQTT, didDisconnectWithError error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
        }
        if let error = error {
            print("Disconnected from the IoT device with error: \(error.localizedDescription)")
        } else {
            print("Disconnected from the IoT device")
        }
    }
    
}
