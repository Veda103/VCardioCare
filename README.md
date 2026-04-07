# VCardioCare 💓

A comprehensive Flutter-based cardiac health monitoring application with AI-powered risk prediction. VCardioCare enables users to track their heart health, receive personalized risk assessments, and manage health data with offline-first architecture.

---

## 📋 Features

### Mobile App (Flutter)
- ✅ **Health Tracking**: Submit health metrics (cholesterol, blood pressure, exercise habits, etc.)
- ✅ **AI Risk Prediction**: Machine learning-based cardiac risk assessment
- ✅ **Dashboard**: Real-time health statistics and prediction history
- ✅ **Profile Management**: User profile editing and preferences
- ✅ **Offline Support**: Local SQLite storage with cloud sync
- ✅ **Push Notifications**: Health reminders and alerts
- ✅ **Background Jobs**: Scheduled health check reminders
- ✅ **Encrypted Storage**: Secure local data with flutter_secure_storage

### Backend API (Node.js/Express)
- RESTful API with MongoDB integration
- User authentication and authorization
- Health data management
- Prediction history tracking
- Push notification services

### ML Engine (Python/FastAPI)
- Random Forest cardiac risk prediction model
- SHAP-based feature importance analysis
- Real-time prediction API
- Artifact management (models, scalers)

---

## 🛠️ Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| **Frontend** | Flutter | 3.x |
| **Language** | Dart | 3.x |
| **State Management** | Provider | 6.x |
| **HTTP Client** | Dio | 5.x |
| **Local Storage** | SQLite | Latest |
| **Secure Storage** | flutter_secure_storage | 9.x |
| **Notifications** | flutter_local_notifications | 17.x |
| **Backend API** | Node.js/Express | LTS |
| **Backend Database** | MongoDB Atlas | Cloud |
| **ML Framework** | Python/FastAPI | 3.13 |
| **ML Libraries** | scikit-learn, pandas, numpy | Latest |
| **Build System** | Gradle (Android) | 7.x |

---

## 📱 Project Structure

```
vcardiocare/
├── lib/                          # Flutter app source code
│   ├── main.dart                 # App entry point
│   ├── app.dart                  # App configuration
│   ├── core/                     # Core utilities & constants
│   │   ├── api/                  # API service
│   │   ├── database/             # SQLite database
│   │   └── storage/              # Secure storage
│   ├── models/                   # Data models
│   ├── providers/                # State management (Provider)
│   │   ├── auth_provider.dart
│   │   ├── prediction_provider.dart
│   │   └── health_provider.dart
│   ├── screens/                  # UI screens
│   │   ├── dashboard_screen.dart
│   │   ├── health_screen.dart
│   │   ├── profile_screen.dart
│   │   └── login_screen.dart
│   └── widgets/                  # Reusable UI components
├── android/                      # Android platform code
│   ├── app/build.gradle.kts     # Android app config
│   ├── gradle/                   # Gradle wrapper
│   └── local.properties          # Local SDK path
├── ios/                          # iOS platform code
├── vcardiocare-backend/          # Node.js Express API
│   ├── server.js                 # Express app
│   ├── package.json              # Dependencies
│   ├── models/                   # MongoDB schemas
│   ├── routes/                   # API endpoints
│   └── middleware/               # Auth & validation
├── vcardiocare-ml/               # Python ML Engine
│   ├── app.py                    # FastAPI server
│   ├── predict.py                # ML prediction logic
│   ├── train.py                  # Model training
│   ├── requirements.txt          # Python dependencies
│   └── artifacts/                # Trained models & scalers
├── test/                         # Flutter tests
├── pubspec.yaml                  # Flutter dependencies
├── DEPLOYMENT_GUIDE.md           # Deploy instructions
└── README.md                     # This file
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: 3.x or higher ([Install](https://flutter.dev/docs/get-started/install))
- **Dart SDK**: Included with Flutter
- **Android SDK**: API 24+ (included with Android Studio)
- **Node.js**: 16+ LTS ([Install](https://nodejs.org/))
- **Python**: 3.10+ ([Install](https://www.python.org/))
- **MongoDB Atlas**: Cloud database account ([Sign up](https://www.mongodb.com/cloud/atlas))
- **Git**: For version control

### Installation

#### 1. Clone Repository
```bash
git clone https://github.com/yourusername/vcardiocare.git
cd vcardiocare
```

#### 2. Setup Flutter App
```bash
# Get Flutter dependencies
flutter pub get

# Check Flutter setup
flutter doctor
```

#### 3. Setup Backend Server
```bash
cd vcardiocare-backend

# Install Node dependencies
npm install

# Create .env file
echo "MONGO_URI=your_mongodb_atlas_connection_string" > .env
echo "PORT=5000" >> .env
echo "JWT_SECRET=your_jwt_secret" >> .env

# Start backend server
npm run dev
# Server runs on http://localhost:5000
```

#### 4. Setup ML Server
```bash
cd vcardiocare-ml

# Create Python virtual environment
python -m venv venv
# On Windows
venv\Scripts\activate
# On macOS/Linux
source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Start ML API server
python app.py
# API runs on http://localhost:8000
```

---

## 🏃 Running the App

### Option 1: Using Flutter CLI
```bash
# List connected devices
flutter devices

# Run debug app
flutter run

# Run release build
flutter build apk --release
flutter build appbundle --release  # For Play Store
```

### Option 2: Using Android Studio
1. Open project in Android Studio
2. Select target device
3. Click **Run** (or press Shift+F10)

### Option 3: Using VS Code
```bash
# Start debugging
flutter run -v
```

---

## 📦 API Endpoints

### Backend API (Node.js)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | User registration |
| POST | `/api/auth/login` | User login |
| GET | `/api/profile` | Get user profile |
| PATCH | `/api/profile` | Update user profile |
| POST | `/api/health/submit` | Submit health data |
| GET | `/api/health/:id` | Get health record |
| POST | `/api/predictions/analyse` | Submit for prediction |
| GET | `/api/predictions/latest` | Get latest prediction |
| GET | `/api/predictions/history` | Get prediction history |

### ML API (Python/FastAPI)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | API health check |
| POST | `/predict` | Get risk prediction |
| GET | `/api/docs` | Swagger documentation |

---

## 🔐 Environment Configuration

### Backend (.env)
```env
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/vcardiocare
PORT=5000
JWT_SECRET=your_super_secret_key_here
NODE_ENV=development
```

### Flutter (lib/core/api_constants.dart)
```dart
const String API_BASE_URL = 'http://localhost:5000/api';
const String ML_API_URL = 'http://localhost:8000';
```

---

## 📊 Database Schema

### MongoDB Collections
- **users**: User accounts and authentication
- **health_inputs**: Health metrics submissions
- **predictions**: Risk prediction results
- **notifications**: Push notification logs

---

## 🧪 Testing

```bash
# Run Flutter widget tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# With coverage
flutter test --coverage
```

---

## 📲 Build & Deployment

### Debug APK
```bash
flutter build apk --debug
```

### Release APK (Unsigned)
```bash
flutter build apk --release
```

### Signed APK (Production)
```bash
# Generate keystore
keytool -genkey -v -keystore vcardiocare-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias vcardiocare-key

# Build signed APK
flutter build apk --release
```

### Play Store Bundle
```bash
flutter build appbundle --release
```

**Latest Release APK**: `build/app/outputs/flutter-apk/app-release.apk` (54.2 MB)

---

## 🐛 Troubleshooting

### Flutter Build Issues
```bash
# Clean build artifacts
flutter clean

# Get fresh dependencies
flutter pub get

# Run with verbose output
flutter run -v
```

### Backend Connection Errors
- Ensure backend is running on `localhost:5000`
- Check MongoDB Atlas connection string
- Verify API_BASE_URL in Flutter config

### ML Server Not Responding
- Check ML server on `localhost:8000`
- Verify Python dependencies installed: `pip install -r requirements.txt`
- Check artifact paths in `predict.py`

---

## 📚 Documentation

- [Flutter Development Guide](https://flutter.dev/docs)
- [Express.js Documentation](https://expressjs.com/)
- [FastAPI Guide](https://fastapi.tiangolo.com/)
- [MongoDB Atlas Guide](https://docs.atlas.mongodb.com/)
- [Deployment Guide](./DEPLOYMENT_GUIDE.md)

---

## 👥 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- scikit-learn for ML tools
- MongoDB for database services
- Contributors and testers
