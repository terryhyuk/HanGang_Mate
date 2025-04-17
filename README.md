# HangangPark

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white)](https://firebase.google.com/)

---

## Table of Contents

- [Overview](#overview)
- [Demo Video](#demo-video)
- [Assigned Role](#assigned-role)
- [Tech Stack](#tech-stack)
- [Flutter Packages](#flutter-packages)
- [How to Run](#how-to-run)
- [Links](#links)
- [Contact](#contact)

---

## Overview

HangangPark is a Flutter-based app that predicts parking lot congestion in Yeouido Hangang Park and Ttukseom Hangang Park using machine learning.

- Provides real-time parking information and future congestion predictions based on holidays, time slots, and parking lot locations.
- Offers navigation assistance to help users find parking spots in real time.

- **Duration/Team Size:**  
  November 1, 2024 – November 22, 2024  
  5-member team project

---

## Demo Video

[![Demo Video](https://img.youtube.com/vi/GxYjpVGlDhHs/0.jpg)](https://youtu.be/GxYjpVGlDhHs)

[Watch on YouTube](https://youtu.be/GxYjpVGlDhHs)

---

## Assigned Role

1. **Data Analysis and Preprocessing of Ddukseom Parking Lot Using Python**
   - Analyzed parking lot data and performed preprocessing tasks to prepare for model development.
2. **Development of Machine Learning-Based Congestion Prediction Model**
   - Built a predictive model to estimate parking lot congestion using machine learning techniques.
3. **Implementation of Prediction Model Using FastAPI**
   - Deployed the machine learning model through FastAPI to enable real-time predictions.
4. **Real-Time API Server for Providing Prediction Results**
   - Established a real-time API server to deliver congestion predictions to users.
5. **Implementation of Real-Time Chat System with Administrators**
   - Developed a chat system for real-time communication between users and administrators.

---

## Tech Stack

**Frameworks:**  
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
<img src="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white"/>

**Languages:**  
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
<img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white"/>

**Database:**  
<img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white"/>
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white"/>

**Design/Planning:**  
<img src="https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white"/>
<img src="https://img.shields.io/badge/Miro-050038?style=for-the-badge&logo=miro&logoColor=white"/>

**Tools:**  
<img src="https://img.shields.io/badge/VSCode-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white"/>
<img src="https://img.shields.io/badge/Scikit-learn-F7931E?style=for-the-badge&logo=scikit-learn&logoColor=white"/>
<img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white"/>
<img src="https://img.shields.io/badge/Jupyter-F37626?style=for-the-badge&logo=jupyter&logoColor=white"/>

---

## Flutter Packages

- `get` (^4.6.6): State management and navigation
- `persistent_bottom_nav_bar` (^6.2.1): Bottom navigation bar
- `http` (^1.2.2): HTTP requests
- `get_storage` (^2.1.1): Local storage management
- `firebase_core` (^3.6.0): Core Firebase functionalities
- `cloud_firestore` (^5.4.3): Firestore database integration
- `google_maps_flutter` (^2.9.0): Google Maps integration
- `flutter_polyline_points` (^2.1.0): Polyline routes for maps
- `geolocator` (^13.0.2): Geolocation services
- `firebase_auth` (^5.3.3): Firebase Authentication
- `google_sign_in` (^6.2.2): Google Sign-In integration
- `lottie` (^3.1.2): Lottie animations
- `chat_bubbles` (^1.6.0): Chat UI widgets
- `gauge_indicator` (^0.4.3): Gauge for parking lot status
- `gradient_slider` (^1.0.2): Gradient-style slider for UI
- `dots_indicator` (^3.0.0): Dots indicator for pagination/progress

---

## How to Run

1. Clone the repository  
   `git clone https://github.com/shinjs99/HanGang-Mate.git`
2. Install Flutter dependencies  
   `flutter pub get`
3. Run the app  
   `flutter run`
4. Backend setup (for ML prediction API):
   - The backend (FastAPI) source code is in the `/pythonSpace` directory (if public).
   - To run the backend:
     1. Open a terminal and go to the `pythonSpace` folder.
     2. (Optional) Create a virtual environment:
        `python3 -m venv venv`
        `source venv/bin/activate`
     3. Install dependencies:
        `pip install -r requirements.txt`
     4. Start the FastAPI server:
        `uvicorn calmlake:app --reload`
   - The Flutter app uses Firebase directly; there is **no separate Firebase folder**.  
     Make sure your Firebase project is set up and configured in your Flutter app as described in the Flutter/Firebase documentation.

---

## Links

- [GitHub Repository](https://github.com/shinjs99/HanGang-Mate)

---

## Contact

For questions, contact:  
**Terry Yoon**  
yonghyuk.terry.yoon@gmail.com
