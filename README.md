# 🌀 LifeSync – Intelligent Task & Schedule Manager  

<p>
  <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/></a>
  <a href="https://dart.dev/"><img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/></a>
  <a href="https://firebase.google.com/"><img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/></a>
  <a href="https://www.tensorflow.org/"><img src="https://img.shields.io/badge/TensorFlow-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white" alt="TensorFlow"/></a>
  <a href="https://flask.palletsprojects.com/"><img src="https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white" alt="Flask"/></a>
  <a href="#"><img src="https://img.shields.io/badge/Status-Prototype-blue?style=for-the-badge" alt="Prototype"/></a>
</p>

---

## 📖 Overview  
**LifeSync** is a prototype mobile application designed to make **personal task management smarter** through:  

- 🔮 **Predictive scheduling** powered by an LSTM model  
- 🔔 **Task reminders** with in-app notifications  
- 🔑 **Secure authentication** via Firebase  
- 📱 **Streamlined interface** for quick task management  

This project demonstrates the potential of integrating **machine learning** into everyday productivity apps while maintaining simplicity and usability.

---

## ✨ Features  

- ✅ Add, edit, and delete tasks  
- ✅ Predictive task scheduling using ML  
- ✅ Push notifications for upcoming tasks  
- ✅ Firebase authentication (signup/login)  
- ✅ Simple and intuitive UI  

---

## 🛠️ Tech Stack  

**Frontend**  
- Flutter  
- Dart  

**Backend**  
- Firebase (Auth, Firestore, Notifications)  
- Flask (API handling for ML integration)  

**Machine Learning**  
- TensorFlow (LSTM model for predictive scheduling)  

---

## 📱 Screenshots  

<table>
  <tr>
    <td><img width="200" alt="Home Screen Drawer" src="https://github.com/user-attachments/assets/7e0f5b0f-ee30-4b08-a9cc-08d8c5c01068" /></td>
    <td><img width="200" alt="Add Task View" src="https://github.com/user-attachments/assets/4508999b-516b-4e82-9c65-3d513013b16e" /></td>
    <td><img width="200" alt="Schedule View" src="https://github.com/user-attachments/assets/d995109c-ea3e-4576-a2a5-fd0106c5a4bd" /></td>
  </tr>
    <tr>
    <th>Home Screen Drawer</th>
    <th>Add Task View</th>
    <th>Schedule View</th>
  </tr>
  <tr>
    <td><img width="200" alt="Schedule View week" src="https://github.com/user-attachments/assets/7d41dd4a-aef4-4ece-a197-c4a736c916ad" /></td>
    <td><img width="200" alt="Task Progress View" src="https://github.com/user-attachments/assets/45341c57-58e1-4170-bfa4-99beb1e1f40b" /></td>
    <td><img width="200" alt="Prediction" src="https://github.com/user-attachments/assets/a01ce779-1ae2-4132-8076-7cc1cc2e8c7d" /></td>
  </tr>
    <tr>
    <th>Schedule View (week)</th>
    <th>Task Progress View</th>
    <th>Prediction View</th>
  </tr>
</table>

---

## ⚙️ Setup Instructions  

1. Clone the Repository  
  ```bash
    git clone https://github.com/BUSHAAN/LifeSync.git
    cd lifesync
  ```
2. Install Dependencies
  ```bash
    flutter pub get
  ```
3. Firebase Setup
- LifeSync requires a Firebase project for authentication, database, and notifications.
- Go to Firebase Console and create a new project.
- Enable Authentication, Firestore Database, and Cloud Messaging.
- Download the google-services.json (for Android) or GoogleService-Info.plist (for iOS).
- Place them in the respective platform folders of your Flutter project:
  - android/app/google-services.json
  - ios/Runner/GoogleService-Info.plist

4. Run the App
  ```bash
  flutter run
  ```

## 🚧 Project Status  
This is a **prototype** and not a production-ready application.  
The machine learning server will be published in a **separate repository**.  
