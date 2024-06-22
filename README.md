# Ekhedmni: Mobile Application for Finding Nearest Auto Repair Shops and Electronics, with Car Repair Assistance Chatbot

## Overview
Ekhedmni is a mobile application built with Flutter that helps users find the nearest auto repair shops and electronics repair services. It also includes a chatbot for car repair assistance. The backend is powered by Flask, and the chatbot functionality is implemented using Rasa.

## Setup and Run Instructions

### Backend Server (Flask)

Navigate to the `backend-server` directory.
Install Required Libraries:
  pip install -r requirements.txt
Run the Flask Server:
  python app.py

### Rasa Chatbot

Navigate to the `rasa-chatbot-car-diagnose` directory.
Install Rasa:
  pip install rasa
Run the Rasa Server:
  rasa run --port 5005

### Flutter Application

Navigate to the `flutter` directory.
Install Dependencies:
  flutter pub get
Run the Flutter App:
  flutter run

### Configuration

#### Updating IP Addresses

To ensure the application works correctly on your local network, update the IP addresses in the Flutter application as follows:

1. Home Screen
   - Line 109:
     Uri.parse('http://192.168.1.6:5000/nearest_repair_shops'),
   - Line 79:
     Uri.parse('http://192.168.1.6:5000/get_repair_types'),

2. Chatbot Screen
   - Line 25:
     Uri.parse('http://192.168.1.6:5005/webhooks/rest/webhook'),

Note:
- Replace `192.168.1.6` with your computer's local IP address if running on a physical device on the same network.
- Use `10.0.2.2` for Android Emulator or `127.0.0.1` for iOS Simulator.

### Running the Application

1. Start the Flask Server:
   Navigate to the `backend-server` directory and run:
   python app.py

2. Start the Rasa Server:
   Navigate to the `rasa-chatbot-car-diagnose` directory and run:
   rasa run --port 5005

3. Build and Run the Flutter App:
   Navigate to the `flutter` directory and run:
   flutter run

### Features
- Auto Repair Shop Locator: Find the nearest auto repair shops based on your location.
- Electronics Repair Locator: Locate nearby electronics repair services.
- Car Repair Assistance Chatbot: Get assistance with car repairs through an interactive chatbot.

### Notes
- Ensure that the Flask server and Rasa chatbot are running before launching the Flutter app.
- Update the IP addresses in the Flutter app as mentioned in the configuration section.
- The backend server should run on port `5000`, and the Rasa server should run on port `5005`.

### Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/yourFeature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/yourFeature`)
5. Open a pull request


