# Implementation Plan: Meal Feature - HbA1c Attribute and Archive Redirect

**Branch**: `001-meal-hba1c-redirect` | **Date**: 2026-04-11 | **Spec**: [spec.md](./spec.md)

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Update the meal creation feature to replace `gluco_percent` with `hba1c` (HbA1c - glycated hemoglobin) in the API response. When the response contains an hba1c value, the mobile app redirects the user to the archives page (`/archives`). When hba1c is absent (user has ≤3 meals), no redirect occurs.

**Technical approach**: Backend already calculates hba1c using Fuzzy logic when user has >3 meals. Frontend needs to check for hba1c presence in response and implement conditional navigation.

## Technical Context

**Language/Version**: Python 3.11 (FastAPI backend), Dart/Flutter (mobile app)  
**Primary Dependencies**: FastAPI, SQLAlchemy, Flutter navigation  
**Storage**: SQLite (existing HealthApp.db)  
**Testing**: pytest (backend), Flutter testing (mobile)  
**Target Platform**: Android/iOS mobile app + Python FastAPI backend  
**Project Type**: Mobile app with REST API backend  
**Performance Goals**: API response time <500ms, redirect within 2 seconds  
**Constraints**: Mobile app must handle offline gracefully  
**Scale**: Single user flow - meal creation with conditional redirect

## Constitution Check

_Not applicable to GlucoTrack project - constitution is specific to HighFive landing page._

## Project Structure

### Documentation (this feature)

```text
specs/001-meal-hba1c-redirect/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (via /speckit.tasks)
```
specs/001-meal-hba1c-redirect/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── tasks.md             # Phase 2 output (via /speckit.tasks) ✅ GENERATED
└── checklists/          # Validation checklists

**Structure Decision**: Web application structure - Backend API + Flutter mobile app

## Phase 0: Research

### Research Tasks

- [x] R1: Understand hba1c calculation in Fuzzy logic system
- [x] R2: Identify when hba1c is included in API response (user has >3 meals)
- [x] R3: Determine current response schema (gluco_percent replacement)
- [x] R4: Understand mobile app navigation mechanism

### Research Findings

All clarifications resolved during `/speckit-clarify` phase:

- Archive route: `/archives`
- API endpoint: `POST /api/meal`
- HbA1c format: Decimal (0-100)
- HbA1c source: Fuzzy logic calculation when user has >3 meals

## Phase 1: Design & Contracts

### Data Model

See `data-model.md` for entity definitions.

### Contracts

This is an internal API - no external contracts needed. The API contract is defined in the schemas.

### Quickstart

See `quickstart.md` for development setup.

## Complexity Tracking

No violations - feature is contained within existing architecture.
