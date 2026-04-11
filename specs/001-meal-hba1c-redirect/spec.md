# Feature Specification: Meal Feature - HbA1c Attribute and Archive Redirect

**Feature Branch**: `001-meal-hba1c-redirect`  
**Created**: 2026-04-11  
**Status**: Draft  
**Input**: User description: "there is an update about the meal feature especially in the backend there is a new attribute instead of the gluco_percent we have hba1c which represent معدل السكر التراكمي and we have also the response of create meal have this attribute either exist or not but the point is when it exists we need to redirect the user to the archives page and when it's not exist in the response we don't redirect the user into the archive page"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Archive Redirect on HbA1c Presence (Priority: P1)

After creating a meal through the mobile app, if the API response includes an HbA1c (hba1c) value, the user is automatically navigated to the archives page to view their comprehensive blood sugar history.

The mobile app MUST also display the HbA1c value with its corresponding risk classification:
- **Normal (طبيعي)**: HbA1c < 5.7%
- **Medium Risk (مقدّمات السكري)**: 5.7% - 6.4%
- **High Risk (داء السكري)**: 6.5% - 7.9%
- **Severe Risk (تحكّم ضعيف)**: ≥ 8.0%

**Why this priority**: This is the core functionality requested - enabling users to see their HbA1c results immediately after a meal entry, providing immediate feedback on their blood sugar management progress.

**Independent Test**: Can be fully tested by creating a meal via API with hba1c value in response and verifying user is redirected to archives page within 2 seconds of receiving response.

**Acceptance Scenarios**:

1. **Given** a user has just completed creating a meal entry via the mobile app, **When** the API response contains the hba1c attribute with a value, **Then** the app automatically navigates the user to the `/archives` page
2. **Given** a user has just completed creating a meal entry via the mobile app, **When** the API response does NOT contain the hba1c attribute, **Then** the user remains on the current screen (no redirect occurs)
3. **Given** a user has created a meal entry, **When** the hba1c attribute is present but has a null or empty value, **Then** the user remains on the current screen (no redirect occurs)

---

### User Story 2 - Backend HbA1c Data in Meal Response (Priority: P2)

The backend system stores and returns HbA1c (hba1c) values in the create meal API response when available, replacing the previous gluco_percent attribute.

**Why this priority**: Ensures the frontend has access to the HbA1c data needed to implement the redirect logic. This is a data infrastructure requirement.

**Independent Test**: Can be tested by calling the create meal API and verifying the response schema includes hba1c field when applicable.

**Acceptance Scenarios**:

1. **Given** a user creates a meal entry with associated blood sugar data, **When** the backend has HbA1c value available (user has more than 3 meals), **Then** the response includes hba1c attribute with the decimal value (e.g., 5.5, 7.2)
2. **Given** a user creates a meal entry without blood sugar data, **When** the backend has no HbA1c value (user has 3 or fewer meals), **Then** the response does NOT include the hba1c attribute

---

### Edge Cases

- What happens when the API response is delayed or times out? - Show appropriate loading indicator, no redirect should occur
- What happens when the network connection is lost after meal creation but before redirect? - Handle gracefully, allow manual navigation to archives
- What happens if hba1c value is outside valid range (< 0 or > 100)? - Validate data before triggering redirect, treat as invalid
- What happens when displaying HbA1c value? - Display risk classification based on standard medical ranges (Normal, Pre-diabetes, Diabetes, Poor Control)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST include hba1c attribute in the create meal API response when HbA1c data is available from backend (user has more than 3 meals)
- **FR-002**: System MUST omit hba1c attribute from the create meal API response when HbA1c data is NOT available (user has 3 or fewer meals)
- **FR-003**: Mobile app MUST redirect user to `/archives` page when hba1c attribute is present in create meal response
- **FR-004**: Mobile app MUST NOT redirect user to archives page when hba1c attribute is absent from create meal response
- **FR-005**: Mobile app MUST NOT redirect user to archives page when hba1c attribute exists but has null/empty value
- **FR-006**: System MUST return ONLY hba1c attribute in the API response schema (remove gluco_percent entirely)
- **FR-007**: System MUST expose create meal endpoint at `POST /api/meal`
- **FR-008**: System MUST return hba1c as decimal value (e.g., 5.5, 7.2) representing percentage
- **FR-009**: Mobile app MUST display HbA1c value with risk classification based on the following ranges:
  - **Normal (طبيعي)**: HbA1c < 5.7%
  - **Medium Risk (مقدّمات السكري - Pre-diabetes)**: 5.7% ≤ HbA1c < 6.5%
  - **High Risk (داء السكري - Diabetes)**: 6.5% ≤ HbA1c < 8.0%
  - **Severe Risk (تحكّم ضعيف - Poor Control)**: HbA1c ≥ 8.0% (high risk for vascular and nerve complications)

### Key Entities *(include if feature involves data)*

- **Meal**: Represents a meal entry created by the user with associated blood sugar metrics
- **PrevAnalyse**: Represents the analysis result containing hba1c calculated from Fuzzy logic system
  - **hba1c**: Decimal value (0-100) representing HbA1c percentage (glycated hemoglobin) - the "معدل السكر التراكمي" (estimated average blood glucose over 2-3 months)
  - **Calculation**: hba1c is calculated using Fuzzy logic based on:
    - Glycemic load (mean GL from user's meals)
    - Physical activity (BMI from user's RiskFactor data)
    - Only calculated when user has more than 3 meals

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users with HbA1c data in response are redirected to `/archives` page within 2 seconds of receiving API response
- **SC-002**: Users without HbA1c data in response are NOT redirected to archives page (remain on current screen)
- **SC-003**: 100% of create meal API responses with hba1c attribute trigger the correct redirect behavior in the mobile app
- **SC-004**: Backend API response schema successfully replaces gluco_percent with hba1c attribute

## Assumptions

- User has stable internet connectivity during meal creation
- Mobile app already has an archives page at `/archives` that can be navigated to
- Backend calculates hba1c using Fuzzy logic when user has more than 3 meals
- The redirect is a client-side navigation action in the mobile app
- HbA1c values are decimal numbers between 0-100 representing percentage (e.g., 5.5%, 7.2%)

---

## Clarifications

### Session 2026-04-11

- Q: What is the exact route/name of the archives page in the mobile app? → A: `/archives` (ArchivesScreen)
- Q: What is the exact API endpoint for creating a meal? → A: `POST /api/meal`
- Q: What is the expected data type/format of the hba1c value? → A: Decimal (e.g., 5.5, 7.2) representing percentage
- Q: Where does the backend get the hba1c value from? → A: Calculated using Fuzzy logic when user has more than 3 meals. Formula: hba1c = Fuzzy(glycemic_load, physical_activity) where glycemic_load = mean(GL from all meals), physical_activity = BMI from user's RiskFactor data
- Q: How should hba1c be displayed/rendered in the UI? → A: Show hba1c value with risk classification:
  - Normal (طبيعي): HbA1c < 5.7%
  - Medium Risk (مقدّمات السكري): 5.7% - 6.4%
  - High Risk (داء السكري): 6.5% - 7.9%
  - Severe Risk (تحكّم ضعيف): ≥ 8.0%
