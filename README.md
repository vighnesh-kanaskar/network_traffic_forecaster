# network_traffic_forecaster

NETRA — Network Intelligence

Explainable and predictive network intelligence for real-time traffic monitoring, threat assessment, and attack-stage forecasting.

NETRA (Network Intelligence) is a cybersecurity project developed for Smart India Hackathon 2026 — Problem Statement SIH26153: AI based Network Attack Forecasting from Network Traffic Data.

The system continuously monitors network traffic, extracts packet and flow-level information, evaluates network risk, forecasts the next probable threat stage, and presents the results through an interactive dashboard.

🎯 Project Objective

Traditional network monitoring mainly focuses on detecting activity that has already happened. NETRA is designed to go a step further by combining real-time traffic intelligence with threat forecasting.

The project aims to:

Monitor live network traffic.

Extract useful packet and flow-level features.

Identify changes in network behavior.

Calculate an evidence-based risk level.

Forecast the next probable threat stage.

Present security events and historical activity in an understandable interface.

Help users understand why a network state is considered risky.

✨ Key Features

📊 Real-Time Security Dashboard

Provides an overview of the current network state, including:

Network risk score

Prediction confidence

Current threat state

Predicted next state

Packet count

Flow count

Unique IP count

Packets per second

Data transferred

🌐 Live Traffic Analysis

NETRA captures and displays network traffic information such as:

Source IP

Destination IP

Protocol

Destination port

Packet activity

Traffic statistics

The dashboard updates as real network activity changes.

🔮 Threat Forecasting

NETRA provides a forecast of the next probable threat stage based on observed network behavior.

The forecast is presented as a security progression rather than only reporting individual packets.

🚨 Security Alerts

The application provides a dedicated security-alert interface for detected or forecasted security events, including severity and descriptions.

🕒 Network History

Network activity and prediction information can be stored and reviewed through the history module.

🔐 Firebase Authentication

NETRA includes user authentication with:

Account creation

Login

Logout

First and last name information

Firebase Authentication integration

Profile information display

🏗️ System Architecture

                    ┌──────────────────────┐
                    │    Live Network      │
                    │       Traffic        │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │   Scapy Packet       │
                    │      Capture         │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Network Monitor &    │
                    │ Feature Extraction   │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │   FastAPI Backend     │
                    │  REST API Services    │
                    └──────────┬───────────┘
                               │
             ┌─────────────────┼─────────────────┐
             │                 │                 │
             ▼                 ▼                 ▼
       Dashboard API     Forecast API      Alerts/History
             │                 │                 │
             └─────────────────┼─────────────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │   Flutter Frontend   │
                    │    NETRA Dashboard   │
                    └──────────────────────┘

🛠️ Technology Stack

Layer

Technology

Frontend

Flutter / Dart

Backend

Python / FastAPI

Network Capture

Scapy

Local Storage

SQLite

Authentication

Firebase Authentication

API Server

Uvicorn

Development

VS Code / Android Studio

📁 Project Structure

network_traffic_forecaster/
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
│
├── lib/
│   ├── backend/
│   │   ├── data/
│   │   ├── services/
│   │   ├── network_monitor.py
│   │   └── main.py
│   │
│   ├── controllers/
│   ├── models/
│   ├── pages/
│   ├── services/
│   ├── theme/
│   ├── app.dart
│   ├── app_shell.dart
│   └── main.dart
│
├── firebase.json
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── .gitignore
└── README.md

Generated files, build artifacts, virtual environments, caches, and the local SQLite database are intentionally excluded from version control.

🔄 How NETRA Works

1. Traffic Capture

The backend uses Scapy to capture packets from the active network interface.

2. Feature Extraction

Relevant traffic information is extracted from packets, including IP addresses, protocols, ports, packet counts, bytes, flows, and TCP activity.

3. Network State Analysis

The collected traffic information is processed to understand the current network activity and security state.

4. Risk Assessment

NETRA calculates a network risk level from the observed traffic characteristics.

5. Threat Forecast

The system determines the next probable threat stage from the current network state and presents a forecast with confidence information.

6. Visualization

FastAPI exposes the processed information through REST endpoints, while the Flutter application continuously retrieves and displays the results.

7. Historical Analysis

Relevant network activity and prediction information can be stored in SQLite for later review.

🔌 API Endpoints

The FastAPI backend currently exposes:

GET /api/dashboard
GET /api/traffic
GET /api/forecast
GET /api/alerts
GET /api/history

When the backend is running, FastAPI's interactive API documentation is available at:

http://127.0.0.1:8000/docs

🚀 Getting Started

Prerequisites

Install:

Flutter SDK

Dart SDK

Python 3

Git

Npcap for Scapy packet capture on Windows

Firebase project configured for authentication

1. Clone the repository

git clone <YOUR_GITHUB_REPOSITORY_URL>
cd network_traffic_forecaster

2. Install Flutter dependencies

flutter pub get

3. Set up the Python backend

Open a terminal in:

lib/backend

Create and activate a virtual environment:

python -m venv venv
.\venv\Scripts\Activate.ps1

Install the required Python packages:

pip install -r requirements.txt

If requirements.txt is not included yet, install the Python dependencies used by the backend before starting the server.

4. Start the FastAPI backend

From lib/backend:

uvicorn main:app --host 0.0.0.0 --port 8000

5. Run the Flutter application

From the project root:

flutter run

For Chrome:

flutter run -d chrome

🔐 Security & Privacy

NETRA is intended as a local network monitoring and cybersecurity research/educational project.

Only monitor networks and devices you are authorized to monitor.

Do not commit passwords, API keys, Firebase service-account credentials, .env files, or other secrets.

The local SQLite database is excluded from version control because it contains locally generated network history.

🎓 SIH 2026 Context

Problem Statement: SIH26153
Title: AI based Network Attack Forecasting from Network Traffic Data

NETRA focuses on moving from purely reactive network monitoring toward predictive network intelligence.

The project demonstrates a practical pipeline:

Live Network Traffic
        ↓
Packet / Flow Features
        ↓
Network State Analysis
        ↓
Risk Assessment
        ↓
Threat Forecast
        ↓
Security Visualization
        ↓
Historical Analysis

📸 Project Demo

Recommended repository assets:

assets/
├── dashboard.png
├── traffic-analysis.png
├── threat-forecast.png
├── security-alerts.png
└── netra-demo.mp4

The demo can show the dashboard responding to changes in real network activity, followed by traffic analysis, threat forecasting, security alerts, and network history.

👨‍💻 Project

NETRA — Network Intelligence

A cybersecurity project focused on real-time network monitoring, explainable risk assessment, and threat forecasting.

Built with:

Flutter • Python • FastAPI • Scapy • SQLite • Firebase

📌 Disclaimer

NETRA is a student/research project created for cybersecurity learning, experimentation, and demonstration. It should not be considered a replacement for enterprise-grade network detection and response systems.
