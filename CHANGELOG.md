# Changelog

All notable changes to the Flutter mobile client should be recorded in this file.

## [Unreleased]

- No unreleased mobile changes recorded after `0.1.0` yet.

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
