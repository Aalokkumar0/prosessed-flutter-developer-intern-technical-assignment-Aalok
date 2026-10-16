# ShopSphere

ShopSphere is a responsive Flutter shopping catalogue powered by the public DummyJSON API. It demonstrates secure authentication, resilient networking, explicit state management, persistent cart behavior, adaptive layouts, and testable feature-first architecture.

> Release APK and demo-video links will be added after device QA and recording.

## Screenshots

Screenshots will be added after the final phone and tablet QA pass. The submission will include at least four phone screenshots and two tablet/landscape screenshots.

## Features

### Implemented mandatory scope

- [x] Splash routing based on a securely stored session
- [x] Validated login form, password visibility, loading and invalid-credential states
- [x] Product grid with 20-item pagination, infinite scroll and pull-to-refresh
- [x] API categories, debounced search, sorting and empty results
- [x] Skeleton loading, recoverable error states and human-readable failures
- [x] Product image carousel, discount, rating, stock, description and reviews
- [x] Quantity selection and out-of-stock protection
- [x] Locally persisted cart with live badge, totals, discounts and quantity updates
- [x] DummyJSON checkout and order-confirmation screen
- [x] Profile data and secure logout; forced logout for expired sessions
- [x] Compact bottom navigation, medium navigation rail and expanded master-detail layout
- [x] 43 unit and widget tests covering models, repositories, use cases, Cubits, networking and cart calculations
- [x] 20+ incremental Conventional Commits

### Bonus scope

- [x] Hero animation between product card and details
- [x] GitHub Actions quality checks
- [ ] Automatic token refresh
- [ ] Offline product cache
- [ ] Wishlist, theme toggle and localization

## Tech stack

- **Flutter 3.47.7 / Dart 3.13.5** - current stable toolchain used for this submission.
- **flutter_bloc** - predictable event-to-state flow with focused Cubits and selective rebuilds.
- **Dio** - a single configured HTTP client with timeouts, auth headers and debug-only logging.
- **get_it** - small, explicit dependency-injection composition root.
- **flutter_secure_storage** - encrypted access and refresh-token persistence.
- **shared_preferences** - lightweight local cart persistence for the assignment-sized payload.
- **cached_network_image / shimmer** - cached product imagery and purposeful loading placeholders.
- **mocktail / bloc_test** - readable unit tests with mocked boundaries and state assertions.

## Architecture

The project uses feature-first clean architecture. Each feature owns its `data`, `domain`, and `presentation` concerns, while reusable infrastructure lives under `lib/core`.

```text
lib/
├── core/
│   ├── di/          # Dependency composition
│   ├── error/       # Typed domain failures
│   ├── network/     # Dio client and secure session store
│   ├── theme/       # Material 3 visual system
│   └── widgets/     # Shared loading, empty and error UI
└── features/
    ├── auth/        # Login, session restoration and user entity
    ├── products/    # Catalogue, filters, details and repository
    ├── cart/        # Persistence, calculations and checkout
    ├── profile/     # Current-user presentation
    └── shell/       # Adaptive application navigation
```

One product request flows as follows:

```text
ProductsPage -> ProductsCubit -> ProductsRepository interface
             -> ProductsRepositoryImpl -> ApiClient -> DummyJSON
             -> Product model/entity -> explicit ProductsState -> UI
```

The domain layer contains entities and repository contracts and has no Flutter, Dio, or persistence imports. Data implementations depend inward on those contracts.

## State management

ShopSphere uses Cubit from `flutter_bloc`. Cubit keeps transitions explicit without the extra event classes that would add ceremony to an app of this size. Feature state remains outside widgets, is easy to mock and test, and `context.select` limits rebuilds for values such as the cart badge.

## Error handling

`ApiClient` maps connectivity errors, timeouts, authentication failures, 404s, server errors and unknown exceptions to typed `AppFailure` values. Repositories expose domain objects rather than Dio responses. Network-driven screens render dedicated loading, success, empty and recoverable failure states. A 401/403 clears secure credentials and returns the user to login with an explanatory message.

## Getting started

Prerequisites: Flutter 3.47.7, Dart 3.13.5, Android Studio with an Android 8.0+ emulator or device.

```bash
git clone <repository-url>
cd prosessed-flutter-assignment
flutter pub get
flutter run
```

No code-generation step or API key is required. Build the release APK with:

```bash
flutter build apk --release
```

## Testing

Run all static and unit checks:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
```

Current result: **43 passing tests**, **0 analyzer issues**, and **71.9% line coverage** across files included by the test run.

## Test credentials

```text
Username: emilys
Password: emilyspass
```

These public DummyJSON credentials are pre-filled on the login screen for reviewer convenience.

## Assumptions and trade-offs

- The cart stores its compact JSON payload in `shared_preferences`; a larger production catalogue would use a queryable local database.
- DummyJSON simulates checkout and does not persist orders server-side.
- Sorting is delegated to supported API query parameters rather than reordering one page locally.
- Expanded layouts use a persistent catalogue/detail split; compact and medium layouts navigate to a dedicated details page.
- Token refresh, offline catalogue caching and bonus personalization were deferred so the mandatory experience and tests could remain coherent.
- Before submission, device/emulator QA, screenshots, the demo recording, signed release artifact and public-link checks must still be completed.

## Author

**Aalok Kumar**  
GitHub: [Aalokkumar0](https://github.com/Aalokkumar0)  
Email: `aalok0601@gmail.com`

## AI usage disclosure

AI assistance was used to help interpret the brief, scaffold implementation, review architecture, and generate test cases. All submitted code must be reviewed and understood by the candidate, who remains responsible for the design decisions, verification, and live technical walkthrough.
