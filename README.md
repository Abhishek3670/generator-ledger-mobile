# 🔋 Genset Ledger Mobile

A modern, cross-platform mobile and web application designed for managing generator bookings, vendors, and billing. This application interfaces with a FastAPI backend to provide real-time updates and comprehensive ledger management.

## 🚀 Key Features

- **Dashboard**: High-level overview of active bookings and generator status.
- **Generator Management**: Track your inventory of generators (Retailer, Permanent, Emergency).
- **Booking System**: Streamlined interface for creating and managing generator rentals.
- **Vendor Management**: Maintain a registry of vendors and rental partners.
- **Billing & Analytics**: Track revenue and billing cycles.
- **Role-Based Access**: Specialized views for Administrators and Operators.

## 🛠️ Technical Stack

- **Framework**: [Flutter](https://flutter.dev) (Current: 3.41.6)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Networking**: [Dio](https://pub.dev/packages/dio) with JWT authentication
- **Navigation**: [Go Router](https://pub.dev/packages/go_router)
- **Theming**: Custom "Clean Authority" Design System

## 🏁 Getting Started

### Prerequisites

This project assumes a manual Flutter installation on Linux.
- **Flutter SDK path**: `~/development/flutter`
- **Backend**: FastAPI service running (usually on port 8001)

### Setup

1. Fetch dependencies:
   ```bash
   ~/development/flutter/bin/flutter pub get
   ```

2. (Optional) Run the analyzer to check for issues:
   ```bash
   ~/development/flutter/bin/flutter analyze
   ```

## 🏃 Running the Application

Since the app requires a connection to a specific backend, you must provide the `API_BASE_URL` at runtime.

### 🌐 Web App (Recommended for Remote Access)
To run the web version and access it via your browser:

```bash
~/development/flutter/bin/flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --dart-define=API_BASE_URL=http://<YOUR_IP>:8001
```

### 💻 Linux Desktop
To run as a native Linux application:

```bash
~/development/flutter/bin/flutter run -d linux --dart-define=API_BASE_URL=http://<YOUR_IP>:8001
```

## 🏗️ Project Structure

```text
lib/
├── app/          # Navigation and routing
├── core/         # API clients, Auth providers, and Shared logic
├── features/     # Feature modules (Billing, Bookings, Dashboard, etc.)
├── shared/       # Common widgets and constants
└── theme/        # UI Design system and styling
```

## 📝 Backend Configuration

The app expects the backend to be running on port `8001`. Ensure your backend's CORS settings allow requests from the origin where this Flutter app is hosted (e.g., `http://localhost:8080`).
