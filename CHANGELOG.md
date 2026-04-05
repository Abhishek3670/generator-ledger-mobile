# Changelog

All notable changes to the Flutter mobile client should be recorded in this file.

## [Unreleased]

- No unreleased mobile changes recorded after `0.3.0` yet.

## [0.3.0]

Status: approved phase-3 bookings baseline  
Basis: reviewed and approved against the FastAPI backend before phase 4

### Added

- Backend-connected bookings feature module with repositories, providers, models, list screen, detail screen, cards, and booking forms.
- Booking detail flow with item rendering, emergency-item highlighting, and capability-gated cancel/delete actions.
- Booking edit flow that supports bulk item update/remove and add-item operations through the supported backend endpoints.
- Emergency fallback selection flow for retailer-out-of-stock booking creation responses.

### Changed

- The `/bookings` route now points to a real bookings module instead of a placeholder screen.
- Bookings flows now bootstrap vendor directory data independently so vendor resolution works even when the user enters bookings first.
- Booking list search now supports booking ID and resolved vendor name filtering.

### Fixed

- Booking create requests now stay aligned to the backend item payload shape.
- Booking forms now validate required dates before submission.
- Booking add-item flow now blocks invalid submissions that provide neither `generator_id` nor `capacity_kva`.
- Booking edit dialog layout was stabilized for AlertDialog constraints.

## [0.2.0]

Status: approved phase-2 directory baseline  
Basis: reviewed and approved against the FastAPI backend before phase 3

### Added

- Directory feature module with segmented navigation between vendors and generators.
- Backend-connected vendor and rental-partner repositories, providers, list views, and create/edit dialogs.
- Backend-connected generator repository, provider, inventory-tab views, and create/edit dialog.
- Shared directory search bar component reused by vendor and generator screens.

### Changed

- App dependency wiring now registers directory repositories/providers and injects the centralized permission service instance for feature gating.
- Router directory tab now points to the implemented feature module instead of the temporary placeholder screen.
- Vendor and generator search/filter behavior is now handled inside dedicated providers and shared UI.

### Fixed

- Vendor and rental-vendor tabs now keep separate loading and error state during concurrent fetches.
- Directory mutation flows now surface backend `detail` messages for validation and conflict failures.
- Generator create/update requests now send the backend-required `capacity_kva` field.
- Unsupported generator delete behavior was removed to stay aligned with the current FastAPI contract.

## [0.1.0]

Status: approved phase-1 foundation baseline  
Basis: reviewed and approved against the FastAPI backend before phase 2

### Added

- JWT-based auth persistence using secure storage.
- Centralized permission defaults aligned to backend capability keys and role defaults.
- Router-based app shell with auth bootstrap behavior and protected navigation flow.

### Changed

- Login now posts the real `/api/login` payload and parses the backend response shape correctly.
- API base URL defaults now target backend port `8000`, with Android emulator support and `API_BASE_URL` override support.
- Logout now calls `/api/logout` with recursion-safe client handling so `401` responses do not retrigger logout loops.
- App bootstrap wiring now initializes auth and API client dependencies explicitly for the routed app shell.

### Fixed

- Removed the incorrect nested `payload` login request body.
- Removed the incorrect assumption that login returns a `capabilities` array.
- Prevented expired or partial auth state from restoring as authenticated.
- Prevented logout recursion from the global `401` interceptor.
