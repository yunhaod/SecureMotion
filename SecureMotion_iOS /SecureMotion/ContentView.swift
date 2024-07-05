
import SwiftUI


struct ContentView: View {
    
    @State private var inputText: String = ""
    @ObservedObject var mqttManager = IoTManager()
    
    var body: some View {
        VStack {
            let topic = "Security"
            Text("Home Security Monitor")
                .font(.title)
            if !mqttManager.isConnected {
                // Connect button
                Button(action: {
                    mqttManager.connectToIoTDevice()
                }) {
                    Text("Connect")
                        .frame(width: 200)
                }
                .buttonStyle(CustomButtonStyle(backgroundColor: Color.blue))
            }
            if mqttManager.isConnected {
                // Subscribe button
                Button(action: {
                    mqttManager.subscribeToTopic(topic: topic)
                }) {
                    Text("Subscribe")
                        .frame(width: 200)
                }
                .buttonStyle(CustomButtonStyle(backgroundColor: Color.green))
                
                // Publish message section
                Text("Publish Message:")
                    .font(.title)
                    .frame(width: 200)
                
                TextField("Type here", text: $inputText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding([.bottom])
                    .frame(width: 230, height: 40)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                    .disableAutocorrection(true)

                Button(action: {
                    let message = inputText
                    mqttManager.publishData(topic: topic, message: message)
                }) {
                    Text("Publish Message")
                        .frame(width: 200)
                }
                .buttonStyle(CustomButtonStyle(backgroundColor: Color.orange))
                
                // Disconnect button
                Button(action: {
                    mqttManager.disconnect()
                }) {
                    Text("Disconnect")
                        .frame(width: 200)
                }
                .buttonStyle(CustomButtonStyle(backgroundColor: Color.red))
                
                Text("Received Message: \(mqttManager.receivedMessage)")
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        
    }
}

#Preview {
    ContentView()
}


struct CustomButtonStyle: ButtonStyle {
    var backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(color: .gray, radius: configuration.isPressed ? 2 : 5, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
