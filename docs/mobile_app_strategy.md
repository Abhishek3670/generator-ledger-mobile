# Generator Ledger Mobile Strategy

## Source Baseline

- Analyzed web app repo: `https://github.com/Abhishek3670/generator-ledger`
- Analyzed commit: `4b0ca59553ebd54d7964b9bd3dea023b104e4b6f`
- Commit date: `2026-03-24`
- Web app version in README: `4.0.1`
- Local Flutter app status: fresh scaffold with a placeholder dashboard in `lib/main.dart`

## What The Web App Actually Is

The original product is not a JavaScript SPA. It is a FastAPI application with:

- HTML pages rendered with Jinja templates
- JSON APIs under `/api/*`
- PostgreSQL persistence
- JWT login for API clients
- session-cookie auth for the browser UI
- role/capability-based access control

For mobile, the correct strategy is to mirror:

- domain rules
- API behavior
- screen intent
- visual language

The mobile app should not try to copy the web app's server-rendered structure.

## Core Domain Model

### Entities

- `Generator`
  - `generator_id`
  - `capacity_kva`
  - `type`
  - `identification`
  - `status`
  - `notes`
  - `inventory_type`: `retailer | permanent | emergency`
  - `rental_vendor_id`
- `Vendor`
  - `vendor_id`
  - `vendor_name`
  - `vendor_place`
  - `phone`
- `RentalVendor`
  - `rental_vendor_id`
  - `vendor_name`
  - `vendor_place`
  - `phone`
- `Booking`
  - `booking_id`
  - `vendor_id`
  - `created_at`
  - `status`: `Confirmed | Pending | Cancelled`
- `BookingItem`
  - `id`
  - `booking_id`
  - `generator_id`
  - `start_dt`
  - `end_dt`
  - `item_status`
  - `remarks`
- `BookingHistory`
- `User`
  - `role`: `admin | operator`

### Important Business Rules

1. `Permanent Genset` records are not bookable stock.
2. Permanent generators must have a `rental_vendor_id`.
3. Bookable stock is only `retailer` and `emergency`.
4. Capacity-based booking should auto-assign from `retailer` stock first.
5. If retailer stock is unavailable but emergency stock exists, booking creation returns `409 retailer_out_of_stock` with suggestions.
6. Explicit emergency generator booking is allowed.
7. If the same vendor already has a confirmed booking with overlapping selected dates, new booking items are merged into that existing booking.
8. Booking items are effectively full-day date bookings when created from the UI: `00:00` to `23:59`.
9. A booking cannot lose all items via bulk update; full removal must use delete booking.
10. Vendor deletion is blocked when bookings reference that vendor.
11. History is audit-oriented and must reflect booking create/update/cancel/delete/item changes.
12. Mobile should use JWT auth flows, not cookie-session browser flows.

## Existing Product Modules

### Authentication

- Login screen
- JWT login via `POST /api/login`
- logout via `POST /api/logout`

### Dashboard

- overview counts
- monthly calendar
- day detail overlay listing vendors, bookings, and assigned generators

### Generators

- three separate inventory sections:
  - Retailer Genset
  - Permanent Genset
  - Emergency Genset
- date filter to show booked/free state
- create/update generator flows

### Vendors

- retailer vendors
- rental vendors
- add/edit/delete flows

### Bookings

- vendor-grouped booking list
- date row per booking item date
- booking detail
- create booking
- edit booking
- cancel booking
- delete booking
- add generator to booking
- bulk update booking items

### Billing

- date-range based billable lines
- temporary rate-per-capacity input
- vendor totals
- print-oriented view on web

### History

- GitLens-like audit timeline
- filters by event category
- searchable event stream

### Admin Settings

- user management
- permission matrix
- monitor view with CPU, memory, temperature

## Mobile Translation Strategy

Do not copy desktop tables directly. Translate them into mobile-native patterns.

### Navigation

- Use bottom navigation for primary operational areas:
  - Dashboard
  - Bookings
  - Directory
  - More
- Put secondary/admin screens under `More`
- Use contextual FABs only on screens where create actions are primary

### Screen Translation

- Dashboard
  - stat cards
  - monthly calendar
  - bottom sheet for selected day bookings
- Bookings list
  - vendor-grouped expandable cards
  - search + chips + date filters
  - tap row opens booking detail screen
- Booking detail
  - summary header
  - list of assigned generator items
  - sticky action bar for modify/cancel/delete based on permissions
- Create booking
  - vendor picker with search
  - capacity/date item builder
  - explicit generator picker mode
  - emergency fallback modal/bottom sheet
- Edit booking
  - existing items as editable cards
  - remove item action with guard against removing all
  - add item section at bottom
- Generators
  - segmented inventory tabs: Retailer / Permanent / Emergency
  - generator cards instead of large tables
  - booking/free badge only when a date filter is active
- Vendors
  - top tabs: Retailer / Rental
  - searchable list cards
- Billing
  - date range picker
  - editable rates by capacity
  - grouped vendor subtotals
- History
  - timeline list with color-coded event badges
- Settings
  - admin-only user list
  - permission matrix as per-capability toggles for selected user
  - monitor as compact metric cards + charts

## Recommended Flutter Architecture

### State and Data

- Keep `provider` because it is already in `pubspec.yaml`
- Keep `dio` for API access
- Add repositories between providers and API client
- Use DTOs for API payloads and domain models for UI

### Suggested Folder Structure

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    api/
    auth/
    config/
    models/
    utils/
    widgets/
  features/
    auth/
    dashboard/
    bookings/
    generators/
    vendors/
    billing/
    history/
    settings/
  shared/
```

### Suggested Packages To Add

- `flutter_secure_storage` for JWT storage
- `go_router` for structured navigation
- `intl` for formatting
- `table_calendar` for dashboard calendar
- `fl_chart` only if monitor charts are implemented now

If Gemini wants to avoid `go_router`, default Navigator 2 is acceptable, but route structure must still be clean.

## Visual Language To Preserve

- Font family direction: `Space Grotesk`
- Primary palette: slate
- Accent palette: amber
- Emergency/high-alert highlight: rose/red
- Surface style:
  - rounded cards
  - light borders
  - soft shadows
  - white surfaces on pale slate gradient background

### UI Semantics

- `Retailer` = neutral/slate or green success context
- `Permanent` = amber context
- `Emergency` = rose context
- destructive actions remain red
- primary actions remain dark slate

## API Surface The Mobile App Should Use

### Auth

- `POST /api/login`
- `POST /api/logout`

### Read APIs

- `GET /api/generators`
- `GET /api/generators/{generator_id}/bookings`
- `GET /api/vendors`
- `GET /api/rental-vendors`
- `GET /api/vendors/{vendor_id}/bookings`
- `GET /api/bookings`
- `GET /api/bookings/{booking_id}`
- `GET /api/billing/lines?from=YYYY-MM-DD&to=YYYY-MM-DD`
- `GET /api/calendar/events`
- `GET /api/calendar/day?date=YYYY-MM-DD`
- `GET /api/monitor/live`
- `GET /api/info`
- `GET /health`

### Write APIs

- `POST /api/generators`
- `PATCH /api/generators/{generator_id}`
- `POST /api/vendors`
- `PATCH /api/vendors/{vendor_id}`
- `DELETE /api/vendors/{vendor_id}`
- `POST /api/rental-vendors`
- `PATCH /api/rental-vendors/{rental_vendor_id}`
- `DELETE /api/rental-vendors/{rental_vendor_id}`
- `POST /api/bookings`
- `POST /api/bookings/{booking_id}/cancel`
- `DELETE /api/bookings/{booking_id}`
- `POST /api/bookings/{booking_id}/items`
- `POST /api/bookings/{booking_id}/items/bulk-update`
- `GET /api/export`

## Delivery Plan For Mobile Build

### Phase 1

- app shell
- theme
- routing
- API client
- JWT auth
- role/capability storage

### Phase 2

- vendors module
- generators module
- shared search/filter components

### Phase 3

- bookings list/detail
- create booking
- edit booking
- emergency fallback flow

### Phase 4

- dashboard calendar
- calendar day details
- booking/generator/vendor cross-links

### Phase 5

- billing
- history timeline

### Phase 6

- admin settings
- permission matrix
- monitor

### Phase 7

- loading/error/empty states
- form validation
- device QA
- API edge-case handling

## Acceptance Targets

1. Mobile login works against the current FastAPI backend using JWT.
2. All inventory types render correctly and enforce permanent/emergency rules.
3. Booking creation supports:
   - explicit generator selection
   - capacity-based auto-assignment
   - emergency fallback suggestion flow
   - merge-into-existing-booking behavior
4. Booking edit respects bulk update constraints.
5. Permissions actually hide or disable restricted actions.
6. Visual styling remains recognizably consistent with the web app while being mobile-native.
