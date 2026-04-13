# Mobile Versioning Guide

This file defines release tracking for the Flutter mobile client in this repository.

## Current Version Position

- `0.3.0`
  Status: approved phase-3 bookings baseline
  Environment: local repository
  Meaning: phase-2 baseline plus backend-connected bookings list/detail/create/edit flows, emergency fallback handling, and capability-gated booking actions.

## Versioning Scheme

Use Semantic Versioning for the mobile app: `MAJOR.MINOR.PATCH`

- `PATCH`
  Use for safe bug fixes, auth fixes, validation fixes, and low-risk UI corrections within an existing phase baseline.

- `MINOR`
  Use for backward-compatible feature delivery such as a completed phase or a substantial new module.

- `MAJOR`
  Use for breaking architectural shifts, incompatible API contract changes, or rollout changes that require coordinated upgrade work.

## Planned Milestone Shape

| Version | Status | Scope |
| --- | --- | --- |
| `0.1.0` | Approved | Phase 1 foundation: app shell, routing, auth persistence, logout safety, permission defaults |
| `0.2.0` | Approved | Phase 2 directory foundation: vendors, generators, repositories, and shared filters |
| `0.3.0` | Approved | Phase 3 booking flows |
| `0.4.0` | Planned | Phase 4 dashboard and calendar flows |
| `0.5.0` | Planned | Phase 5 billing and history |
| `0.6.0` | Planned | Phase 6 admin settings and monitor |
| `1.0.0` | Future target | Production-ready mobile release after all major phases, QA, and contract validation |

## Source Of Truth

For each mobile release, keep these aligned:

- [pubspec.yaml](/W:/Aatish/Stuff/gensetledgermobile/flutter_app/pubspec.yaml) -> Flutter app version
- [VERSIONING.md](/W:/Aatish/Stuff/gensetledgermobile/flutter_app/VERSIONING.md) -> release rules and phase milestones
- [CHANGELOG.md](/W:/Aatish/Stuff/gensetledgermobile/flutter_app/CHANGELOG.md) -> mobile change summary

Backend and product truth still come from:

- [web_app_source/web/app.py](/W:/Aatish/Stuff/gensetledgermobile/flutter_app/web_app_source/web/app.py)
- [web_app_source/core/services.py](/W:/Aatish/Stuff/gensetledgermobile/flutter_app/web_app_source/core/services.py)
- [web_app_source/core/permissions.py](/W:/Aatish/Stuff/gensetledgermobile/flutter_app/web_app_source/core/permissions.py)

## Release Rules

1. Do not reuse a mobile version number for different code.
2. Only mark a phase version as approved after review passes against the backend and product behavior.
3. Prompt JSON files and review artifacts are not release artifacts and must not be committed.
4. Keep each commit aligned to a review boundary where possible.
5. Update this file and [CHANGELOG.md](/W:/Aatish/Stuff/gensetledgermobile/flutter_app/CHANGELOG.md) whenever a phase baseline is approved.
