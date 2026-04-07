# Reference Measurement Feature Template

This is the MANDATORY template for all features in GlucoTrack. When implementing or refactoring a feature, copy this structure EXACTLY.

## Rules to Follow

1. **State Pattern (Freezed Required)**:
   - Must have `initial`, `loading`, `loaded`, `error`, and `empty` states
   - Use sealed unions from freezed for type safety

2. **Cubit Pattern**:
   - Use Cubit (not full Bloc) for state management
   - Must implement `load()`, `refresh()`, and mutation methods (e.g., `addMeasurement()`)
   - On mutation success, trigger global refresh

3. **Refresh Integration**:
   - Use `sl<GlobalRefresher>().triggerRefresh()` for mutation success
   - Listen to refresher stream in UI and call `cubit.refresh()`

4. **UI Pattern**:
   - Use `RefreshIndicator` with `onRefresh: cubit.refresh`
   - Use BlocConsumer/BlocBuilder with:
     - Loading: `core/widgets/states/loading_state.dart`
     - Error: `core/widgets/states/error_state.dart` with retry button
     - Loaded: Display data
     - Empty: `core/widgets/states/empty_state.dart`

5. **Barrel File**:
   - Export all important public classes/widgets from `measurement_barrel.dart`

6. **Dependencies**:
   - Use sl<> for dependency injection
   - Use AppException, logger, and other core utilities
