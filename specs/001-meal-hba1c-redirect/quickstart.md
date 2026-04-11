# Quickstart: Meal Feature - HbA1c Attribute and Archive Redirect

## Prerequisites

- Python 3.11+ for backend
- Flutter SDK for mobile app
- SQLite database (existing HealthApp.db)

## Backend Setup

1. Navigate to Backend directory:
   ```bash
   cd Backend
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the FastAPI server:
   ```bash
   uvicorn main:app --reload
   ```

## Mobile App Setup

1. Navigate to frontend directory:
   ```bash
   cd frontend
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Testing the Feature

### Manual Test (Backend)

Create a meal via API:
```bash
curl -X POST "http://localhost:8000/api/meal" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Breakfast - eggs and toast",
    "meal_type": "After Meal",
    "meal_time": "2026-04-11T08:00:00"
  }'
```

**Expected Response (User has >3 meals):**
```json
{
  "message": "Analysis Arrived!",
  "archive": {
    "hba1c": 5.7,
    ...
  }
}
```

**Expected Response (User has ≤3 meals):**
```json
{
  "message": "Meal created successfully",
  "archive": {
    // hba1c field NOT present
    ...
  }
}
```

### Manual Test (Mobile)

1. Create a meal entry
2. If response contains hba1c → app navigates to `/archives`
3. If response does NOT contain hba1c → app stays on current screen

## Key Files to Modify

- `Backend/repositories/mealRepo.py` - Already contains hba1c logic
- `Backend/schemas.py` - Already has hba1c field
- `Backend/routers/meal.py` - Meal creation endpoint
- `frontend/lib/screens/` - Add redirect logic in meal creation handler
- `frontend/lib/services/` - API service for meal creation
