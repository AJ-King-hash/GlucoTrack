# Widget Integration Plan - Archives & Chat Pages

## Overview

This plan outlines the integration of newly created UI components (PaginationWidget, SearchBarWidget, FilterWidget) into the Archives and Chat pages to enable pagination, search, and filtering functionality.

## Objectives

1. Integrate pagination, search, and filter widgets into the Archives page
2. Integrate pagination and search widgets into the Chat/Conversations page
3. Ensure consistent user experience across both features
4. Optimize performance with proper state management

## Current State

### New Widgets Created

- [`frontend/lib/core/widgets/pagination_widget.dart`](../../lib/core/widgets/pagination_widget.dart) - Load-more pagination component
- [`frontend/lib/core/widgets/search_bar_widget.dart`](../../lib/core/widgets/search_bar_widget.dart) - Search input with debounce
- [`frontend/lib/core/widgets/filter_widget.dart`](../../lib/core/widgets/filter_widget.dart) - Filter chips and bottom sheet

### Existing Pages to Update

1. **Archives Page** - Display and manage meal analysis archives
2. **Chat Page** - Display conversations and messages

## Implementation Steps

### Step 1: Integrate Widgets into Archives Page

**Files to Modify:**

- `frontend/lib/features/archives/presentaiton/view/archives_page.dart`

**Changes:**

1. Add `SearchBarWidget` at the top of the archives list
2. Add `FilterChipWidget` below search for risk filtering (Low/Medium/High)
3. Add `PaginationWidget` at the bottom of the list
4. Wrap the list in `NotificationListener<ScrollNotification>` for scroll-based loading
5. Update state management to handle search/filter changes

**Implementation Details:**

```dart
// Add to ArchivesPage
SearchBarWidget(
  hintText: 'Search archives...',
  onSearch: (query) => context.read<ArchiveCubit>().searchArchives(query),
),

FilterChipWidget(
  options: ['Low', 'Medium', 'High'],
  selectedOption: state.riskFilter,
  onSelected: (filter) => context.read<ArchiveCubit>().filterByRisk(filter),
),

// In the list view
PaginationWidget(
  currentPage: state.currentPage,
  totalCount: state.totalCount,
  limit: state.limit,
  isLoading: state.status == ArchiveStatus.loading,
  onLoadMore: () => context.read<ArchiveCubit>().loadMore(),
),
```

### Step 2: Integrate Widgets into Chat Page

**Files to Modify:**

- `frontend/lib/features/chat/presentation/view/chat_list_page.dart` (conversations list)
- `frontend/lib/features/chat/presentation/view/chat_page.dart` (messages)

**Changes (Chat List Page):**

1. Add `SearchBarWidget` at the top of conversations list
2. Add `PaginationWidget` for loading more conversations
3. Update BotCubit with search functionality

**Changes (Chat Messages Page):**

1. Add `PaginationWidget` for loading older messages
2. Implement scroll-to-load-more behavior

### Step 3: Update Chat Cubit

**Files to Modify:**

- `frontend/lib/features/chat/presentation/manager/chat_cubit.dart`
- `frontend/lib/features/chat/presentation/manager/chat_state.dart`

**Changes:**

1. Add pagination state (currentPage, totalCount, hasMore)
2. Add search functionality
3. Add loadMore() method for conversations

### Step 4: Add Sort Options UI

**Files to Modify:**

- `frontend/lib/features/archives/presentaiton/view/archives_page.dart`

**Changes:**

1. Add sort dropdown or chips (analysed_at, gluco_percent, risk_result)
2. Add ascending/descending toggle

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    ArchivesPage                          │
├─────────────────────────────────────────────────────────┤
│  SearchBarWidget ─────► ArchiveCubit.searchArchives()  │
│  FilterWidget ────────► ArchiveCubit.filterByRisk()    │
│  SortWidget ──────────► ArchiveCubit.sortArchives()    │
├─────────────────────────────────────────────────────────┤
│                    ListView                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │              ArchiveCard                        │   │
│  │              ArchiveCard                        │   │
│  │              ArchiveCard                        │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  PaginationWidget ─────► ArchiveCubit.loadMore()      │
└─────────────────────────────────────────────────────────┘
```

## Testing Plan

1. **Unit Tests:**
   - Test ArchiveCubit search/filter/sort methods
   - Test BotCubit pagination methods

2. **Widget Tests:**
   - Test SearchBarWidget input and callbacks
   - Test FilterChipWidget selection
   - Test PaginationWidget display logic

3. **Integration Tests:**
   - Test full search flow (input → API call → display results)
   - Test pagination flow (scroll → load more → display)

## Timeline

- **Phase 1: Archives Page Integration** - 1 day
- **Phase 2: Chat Page Integration** - 1 day
- **Phase 3: Testing** - 0.5 day
- **Total: 2.5 days**

## Risk Assessment

| Risk                            | Impact | Mitigation                           |
| ------------------------------- | ------ | ------------------------------------ |
| Performance with large datasets | Medium | Implement proper pagination limits   |
| Search API rate limiting        | Low    | Add debounce to search input         |
| State management complexity     | Medium | Use Cubit for clean state separation |

## Files to Create/Modify

### New Files

- None (widgets already created)

### Modified Files

1. `frontend/lib/features/archives/presentaiton/view/archives_page.dart`
2. `frontend/lib/features/archives/presentaiton/manager/archives_cubit.dart`
3. `frontend/lib/features/archives/presentaiton/manager/archives_state.dart`
4. `frontend/lib/features/chat/presentation/view/chat_list_page.dart`
5. `frontend/lib/features/chat/presentation/manager/chat_cubit.dart`
6. `frontend/lib/features/chat/presentation/manager/chat_state.dart`
7. `frontend/lib/features/chat/presentation/view/chat_page.dart`

## Expected Outcome

After implementation:

- Users can search archives by meal name/description
- Users can filter archives by risk level (Low/Medium/High)
- Users can sort archives by date, glucose percentage, or risk result
- Users can paginate through archives with load-more functionality
- Users can search and paginate through chat conversations
- Users can paginate through chat messages
- Consistent UI/UX across Archives and Chat features
