# Tasks: Meal Feature - HbA1c Attribute and Archive Redirect

**Feature**: Meal Feature - HbA1c Attribute and Archive Redirect  
**Branch**: `001-meal-hba1c-redirect`  
**Generated**: 2026-04-11

## Phase Structure Overview

| Phase   | Name         | Description                              |
| ------- | ------------ | ---------------------------------------- |
| Phase 1 | Setup        | Environment preparation                  |
| Phase 2 | Foundational | Common tasks blocking user stories       |
| Phase 3 | User Story 1 | Archive Redirect on HbA1c Presence (P1)  |
| Phase 4 | User Story 2 | Backend HbA1c Data in Meal Response (P2) |
| Phase 5 | Polish       | Edge cases and final testing             |

---

## Phase 1: Setup ✅

_Goal_: Prepare development environment for the feature implementation

**Independent Test**: N/A - Setup phase

### Tasks

- [x] T001 Verify Python 3.11+ and Flutter SDK are installed
- [x] T002 [P] Navigate to Backend directory and verify dependencies: `pip install -r requirements.txt`
- [x] T003 [P] Navigate to frontend directory and verify dependencies: `flutter pub get`
- [x] T004 Verify database exists at `Backend/HealthApp.db`

---

## Phase 2: Foundational ✅

_Goal_: Identify and prepare the code locations that will be modified for this feature

**Independent Test**: N/A - Foundational phase

### Tasks

- [x] T005 [P] Locate meal creation endpoint in `Backend/routers/meal.py`
- [x] T006 [P] Review existing hba1c handling in `Backend/repositories/mealRepo.py` (lines 64-85)
- [x] T007 [P] Review response schema in `Backend/schemas.py` for hba1c field
- [x] T011b [P] Verify `POST /api/meal` endpoint is accessible and returns correct response format
- [x] T008 Locate mobile app meal creation screens.
- [x] T009 Locate mobile app API service for meal creation in `frontend/lib/core/api`
- [x] T010 Locate archives screen route definition in frontend

---

## Phase 3: User Story 1 - Archive Redirect on HbA1c Presence (P1)

_Goal_: Implement redirect logic in mobile app - when API response contains hba1c and it's not null, navigate to archives page

**Independent Test**: Create a meal via mobile app with user having >3 meals and verify redirect to /archives within 2 seconds

### Story Goal

After creating a meal through the mobile app, if the API response includes an hba1c value and it's value isn't null, the user is automatically navigated to the archives page.

### Tasks

- [x] T011 [US1] Identify where meal creation API response is handled in frontend service
- [x] T012 [US1] [P] Modify frontend meal creation service to extract hba1c from response
- [x] T013 [US1] Implement conditional navigation: if response contains hba1c and doesn't equal to null, navigate to `/archives`
- [x] T014 [US1] Implement conditional navigation: if response does NOT contain hba1c, stay on current screen
- [x] T015 [US1] Handle case where hba1c exists but is null/empty - do not redirect
- [x] T016 [US1] Display HbA1c value with risk classification on archives screen:
  - Normal (طبيعي): HbA1c < 5.7%
  - Medium Risk (مقدّمات السكري): 5.7% - 6.4%
  - High Risk (داء السكري): 6.5% - 7.9%
  - Severe Risk (تحكّم ضعيف): ≥ 8.0%
    , and the proper keys in the locale_cubit for these results

### Acceptance Criteria Validation

1. ✅ **Given** user has >3 meals **When** creates meal **Then** response has hba1c → redirect to `/archives` AND display hba1c with risk classification
2. ✅ **Given** user has ≤3 meals **When** creates meal **Then** response has no hba1c → no redirect

**Risk Classification Display Rules**:

- Normal (طبيعي): HbA1c < 5.7%
- Medium Risk (مقدّمات السكري): 5.7% - 6.4%
- High Risk (داء السكري): 6.5% - 7.9%
- Severe Risk (تحكّم ضعيف): ≥ 8.0%

---

## Phase 4: User Story 2 - Backend HbA1c Data in Meal Response (P2)

_Goal_: Verify backend correctly returns hba1c in API response

**Independent Test**: Call create meal API and verify response schema matches requirements

### Story Goal

The backend system stores and returns hba1c values in the create meal API response when available (user has >3 meals), replacing the previous gluco_percent attribute where applicable.

### Tasks

- [x] T017 [US2] [P] Verify hba1c is calculated when user has >3 meals (Backend/repositories/mealRepo.py:64-85)
- [x] T018 [US2] [P] Verify hba1c is set to null when user has ≤3 meals (Backend/repositories/mealRepo.py:93)
- [x] T019 [US2] Test API with user having >3 meals - confirm hba1c present in response
- [x] T020 [US2] Test API with user having ≤3 meals - confirm hba1c omitted from response
- [x] T021 [US2] Verify hba1c is returned as decimal type (not string) in API response

### Acceptance Criteria Validation

1. ✅ **Given** user has >3 meals **When** creates meal **Then** response includes hba1c with decimal value (e.g., 5.5, 7.2)
2. ✅ **Given** user has ≤3 meals **When** creates meal **Then** response does NOT include hba1c attribute

---

## Phase 5: Polish & Cross-Cutting Concerns

_Goal_: Handle edge cases and final testing

### Tasks

- [x] T022 Handle API timeout - show loading indicator, do not redirect on timeout
- [x] T023 Handle network failure after meal creation - allow manual navigation to archives
- [x] T024 Validate hba1c values are within 0-100 range; reject any value outside this range as invalid
- [x] T025 Final integration test - full flow from meal creation to redirect verification with risk classification display

---

## Dependencies & Execution Order

```
Phase 1 (Setup)
    ↓
Phase 2 (Foundational) - Can run T005-T010 in parallel
    ↓
Phase 3 (User Story 1) - Requires Phase 2 complete
    ↓
Phase 4 (User Story 2) - Can run in parallel with Phase 3 (different files)
    ↓
Phase 5 (Polish)
```

### Parallel Execution Opportunities

| Tasks                            | Reason                                        |
| -------------------------------- | --------------------------------------------- |
| T002 + T003                      | Independent directories (Backend vs frontend) |
| T005 + T006 + T007 + T011b       | Different backend files, no dependencies      |
| T011 + T012 + T013               | Must be sequential (response handling)        |
| T017 + T018 + T019 + T020 + T021 | Backend verification, can run after Phase 2   |

---

## Implementation Strategy

**MVP Scope**: Phase 3 (User Story 1) - This is the core feature requested. Implement redirect logic in mobile app.

**Incremental Delivery**:

1. First deliver: Phase 3 - Frontend redirect on hba1c presence
2. Then verify: Phase 4 - Backend hba1c response (should already work)
3. Finally: Phase 5 - Polish and edge cases

---

## Summary

| Metric                    | Count                  |
| ------------------------- | ---------------------- |
| Total Tasks               | 26                     |
| Setup Tasks               | 4                      |
| Foundational Tasks        | 7                      |
| User Story 1 Tasks        | 6                      |
| User Story 2 Tasks        | 5                      |
| Polish Tasks              | 4                      |
| Parallelizable Tasks      | 12                     |
| Independent Test Criteria | 2 (one per user story) |

**MVP Recommendation**: Complete Phase 3 (T011-T016) first - this delivers the core feature of redirecting to archives with risk classification display when hba1c is present.
