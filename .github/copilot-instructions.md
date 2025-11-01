# TreatTracker - Flutter Web App with Firebase

## Project Overview
TreatTracker is a Flutter web application with Firebase backend that helps families plan their Halloween trick-or-treat routes by showing which houses are participating.

## Features
- Parent login interface (Firebase Authentication)
- Address registration and candy participation status
- Public anonymous map view showing participating houses
- Google Maps integration for route planning

## Tech Stack
- Flutter Web
- Firebase Authentication
- Cloud Firestore
- Google Maps API

## Project Structure
- `lib/features/` - Feature-based modules (auth, map, admin)
- `lib/models/` - Data models
- `lib/services/` - Firebase and API services
- `lib/widgets/` - Reusable UI components
- `lib/utils/` - Helper functions and constants

## Development Guidelines
- Follow Flutter best practices
- Use provider or riverpod for state management
- Implement responsive design for web
- Ensure Firebase security rules protect user data
- Use environment variables for API keys
