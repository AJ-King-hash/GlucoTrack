# Research: Meal Feature - HbA1c Attribute and Archive Redirect

## Overview

This document captures research findings for implementing the HbA1c attribute replacement and archive redirect feature.

## Research Tasks Completed

### R1: HbA1c Calculation in Fuzzy Logic System

**Finding**: The backend uses Fuzzy logic to calculate hba1c based on:
- Glycemic load (mean GL from all user meals)
- Physical activity (BMI from user's RiskFactor data)

The Fuzzy system is defined in `Backend/FuzzyTraining/Fuzzy.py` with rules mapping GL + activity levels to HbA1c categories (healthy, pre-diabetic, diabetic).

**Source**: `Backend/repositories/mealRepo.py` lines 64-85

### R2: When hba1c is Included in Response

**Finding**: hba1c is calculated and included in the response ONLY when:
- User has MORE than 3 meals (checked via `checking.count()>3`)
- Prior to 3 meals, hba1c is set to `None`

This is a design decision to ensure sufficient data for accurate HbA1c calculation.

**Source**: `Backend/repositories/mealRepo.py` lines 64, 93

### R3: Current Response Schema

**Finding**: The response structure already includes hba1c in the PrevAnalyse model:
- `models.PrevAnalyse.hba1c` field (Float, nullable)
- Schema includes `hba1c: Optional[float] = None`

The feature is partially implemented - backend already returns hba1c when available. The gap is frontend handling.

**Source**: `Backend/models.py`, `Backend/schemas.py`

### R4: Mobile App Navigation

**Finding**: The mobile app uses Flutter navigation. The archives page is at route `/archives`.

**Confirmed via**: Clarification session with user

## Decisions

| Decision | Rationale | Alternatives Considered |
|----------|-----------|-------------------------|
| Use hba1c instead of gluco_percent | User explicitly requested this change | Keep both (rejected - user wants replacement) |
| Redirect to /archives when hba1c present | User explicitly requested redirect behavior | Show toast (rejected - user wants direct navigation) |
| hba1c = null for ≤3 meals | Need sufficient data for accurate calculation | Calculate anyway (rejected - inaccurate results) |
