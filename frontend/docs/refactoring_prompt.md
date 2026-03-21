# Refactoring Prompts:

## Scope (A): mutation toast + always refresh (quick wins, high impact)

```md
We are refactoring GlucoTrack to improve data consistency and refresh behavior without creating new pages, cards or widget types.

Rules (must follow exactly):

1. Single source of truth = Cubit state
2. Use Hive for caching (already in project) — network-first, fallback to cache on error
3. After EVERY mutation (success OR failure) → call sl<GlobalRefresher>().triggerRefresh()
4. Show feedback for every mutation via ToastUtility (success or error)
5. Do NOT create new widget classes — only modify logic inside existing files
6. Do NOT leave partial implementations — either finish completely (with loading/error handling) or explain why it's not possible right now
7. Do NOT change visual appearance or layout unless it's clearly broken

Task for this session:

Focus on **mutation flows** first (Scope A).

1. Find the places where mutations(create/update/delete) of the user is used.

2. In each mutation function:
   - Add success toast using ToastUtility.showSuccess(...)
   - Add error toast using ToastUtility.showError(...) with user-friendly message
   - After success AND after error: call sl<GlobalRefresher>().triggerRefresh()
3. In pages/tabs that display important data (especially home tabs):
   - Add listener to GlobalRefresher in initState
   - When event received → call .refresh() or .load() on the relevant cubit
4. Do NOT remove existing logic — extend/wrap it
5. Show before/after for each modified function/file
6. If you cannot complete a mutation pattern fully — explain exactly why and what is missing

Start with the most common mutation flows (meal logging and glucose entry are good candidates).
```

## Scope (B): Scope B — one feature with proper cache + cubit as source of truth
