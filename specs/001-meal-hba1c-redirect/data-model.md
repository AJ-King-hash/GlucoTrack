# Data Model: Meal Feature - HbA1c Attribute and Archive Redirect

## Entities

### Meal

**Description**: Represents a meal entry created by the user with associated blood sugar metrics

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | Integer | Primary Key | Unique meal identifier |
| description | String | Required, max 500 chars | User's meal description |
| meal_type | Enum | Required | "Fast", "Before Meal", "After Meal" |
| meal_time | DateTime | Required | When the meal was consumed |
| user_id | Integer | Foreign Key | Reference to user |
| GL | Float(2) | Optional | Glycemic Load value |

---

### PrevAnalyse (Previous Analysis)

**Description**: Represents the analysis result containing hba1c calculated from Fuzzy logic system

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | Integer | Primary Key | Unique analysis identifier |
| user_id | Integer | Foreign Key | Reference to user |
| meal_id | Integer | Foreign Key | Reference to meal |
| gluco_percent | Float(2) | Optional | Average glucose percentage |
| hba1c | Float(2) | Nullable | HbA1c value (معدل السكر التراكمي) - only present when user has >3 meals |
| risk_result | String | Required | Risk assessment ("Low", "Medium", "High") |
| analysed_at | DateTime | Required | When analysis was performed |
| recommendations | String | Optional | Health recommendations |
| meal_tips | String | Optional | Meal-related tips |

**Relationships**:
- One Meal → Many PrevAnalyse (one meal can have one analysis)
- One User → Many PrevAnalyse

---

### RiskFactor

**Description**: User's health risk factors including BMI for HbA1c calculation

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | Integer | Primary Key | Unique identifier |
| user_id | Integer | Foreign Key | Reference to user |
| BMI | Float | Required | Body Mass Index for Fuzzy logic calculation |

---

## Validation Rules

From requirements:

- **FR-002**: hba1c MUST be omitted (null) when user has ≤3 meals
- **FR-008**: hba1c MUST be decimal value (e.g., 5.5, 7.2) representing percentage

## State Transitions

### Meal Creation Flow

```
User creates meal
    ↓
Check meal count for user
    ↓
[If >3 meals]
    → Calculate hba1c using Fuzzy(mean(GL), BMI)
    → Include hba1c in response
    → (Frontend redirects to /archives)
    
[If ≤3 meals]
    → hba1c = null/omit
    → (Frontend does NOT redirect)
```

## API Response Schema

### Create Meal Response

```json
{
  "message": "Meal created successfully",
  "archive": {
    "id": 1,
    "user_id": 123,
    "meal_id": 456,
    "gluco_percent": 10.5,
    "hba1c": 5.7,        // Present when user has >3 meals
    "risk_result": "Low",
    "analysed_at": "2026-04-11T10:30:00Z",
    "recommendations": "...",
    "meal_tips": "..."
  }
}
```

**Note**: When hba1c is not available (≤3 meals), the field is completely omitted from the response, not set to null.
