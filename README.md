# Real-time Disaster Mapping & Prediction Platform

A **real-time, multi-functional web and mobile-based disaster management platform** tailored to the Sri Lankan context, integrating geospatial data, predictive machine learning models, and user-generated content to enhance public awareness, route safety, and community engagement during natural and environmental hazards such as floods, landslides, and and traffic disruptions.

---

## 🧩 Project Overview

This platform aims to provide citizens and authorities with **real-time disaster information, risk prediction, and safety tools** to respond effectively during emergencies. The system combines:

- **Interactive Map Visualization**: Displays disaster zones, hazards, and risk areas in real time.
- **AI/ML-based Hazard Prediction**: Predicts hazard zones using terrain, weather, and sensor data.
- **User-generated Content**: Allows verified users to report hazards, share photos/videos, and update communities.
- **Route Safety and Notifications**: Suggests safe paths during emergencies using AI-powered hazard detection.
- **Resource Management & Donations**: Tracks donation items, rescues camps, and allocates resources to affected individuals.

---

## 👥 Team Members & Modules

| Team Member | Module / Responsibility |
|-------------|------------------------|
| **You (Project Lead)** | **Real-time Disaster Mapping & Prediction** <br> - Display disaster zones on maps <br> - CRUD operations for admin <br> - ML-based hazard prediction |
| **Member 2** | **Route Planning & Safety Notification** <br> - User route input <br> - AI-powered hazard detection <br> - Real-time safety alerts |
| **Member 3** | **Donation & Rescue Camp Management** <br> - Add/manage donations <br> - Auto-detect number of people in rescue camps <br> - Allocate resources efficiently |
| **Member 4** | **Community Messaging & Media Sharing** <br> - Chat system <br> - Share photos/videos <br> - Report hazards & create posts <br> - Real-time disaster updates |

---

## ⚙️ Technologies Used

- **Frontend**: Flutter (Android & iOS mobile apps, cross-platform)  
- **Backend**: Spring Boot (REST API, database management, business logic)  
- **Machine Learning**: Python (predictive hazard models using weather & terrain data)  
- **Database**: PostgreSQL / MySQL (for storing disaster data, user content, and donations)  
- **Geospatial Tools**: Google Maps API / Mapbox for hazard mapping and route visualization  

---

## 🛠 Features

### Real-time Disaster Mapping & Prediction
- Display disaster zones and predicted risk areas on an interactive map
- Admin panel for CRUD operations on hazard data
- Predict risk levels using ML models (Python)

### Route Planning & Safety
- Users input routes and receive AI-powered safety assessments
- Real-time alerts for hazards along the route
- Suggest alternative safe paths

### Donation & Rescue Camp Management
- Users can add donations and view rescue camp needs
- Automatically detect and manage the number of people in camps
- Optimize distribution of resources

### Community Messaging & Media Sharing
- Real-time chat system
- Share photos, videos, and hazard reports
- Verified user media updates for public awareness

---

## 📦 Project Structure


---

## 🔧 Installation & Setup

### Backend (Spring Boot)
```bash
# Clone the repository
git clone <repo-url>

# Navigate to backend
cd backend

# Build and run
./mvnw spring-boot:run

# Navigate to frontend
cd frontend

# Get dependencies
flutter pub get

# Run app (Android/iOS)
flutter run

# Navigate to ML folder
cd ml-models

# Install dependencies
pip install -r requirements.txt

# Run model script
python hazard_prediction.py
