# Flutter Deterministic Blueprint

> A clean, scalable, highly debuggable Flutter architecture. Once you see a screen, you can predict exactly where its notifier, logic, and widgets live.

---

## Table of Contents

1. [Core Philosophy](#1-core-philosophy)
2. [Widget Rules](#2-widget-rules)
3. [Code Documentation Standards](#3-code-documentation-standards)
4. [Performance Optimization](#4-performance-optimization)
5. [Folder Structure Overview](#5-folder-structure-overview)
6. [lib/app](#6-libapp)
7. [lib/core](#7-libcore)
   - [base](#71-corebase)
   - [enums](#72-coreenums)
   - [utils](#73-coreutils)
8. [lib/data](#8-libdata)
9. [lib/network](#9-libnetwork)
10. [lib/shared](#10-libshared)
11. [lib/features](#11-libfeatures)
    - [ui layer](#111-ui-layer)
    - [logic layer](#112-logic-layer)
    - [providers / state layer](#113-providers--state-layer)
12. [Riverpod State Pattern (Pod Structure)](#12-riverpod-state-pattern-pod-structure)
    - [Pod Definition & me Accessor](#121-pod-definition--me-accessor)
    - [State Definition with Equatable](#122-state-definition-with-equatable)
    - [Extension Part Files (ext_on_*_pod.dart)](#123-extension-part-files-ext_on__poddart)
    - [Extension Helpers on Providers](#124-extension-helpers-on-providers)
    - [Controller Lifecycle Management](#125-controller-lifecycle-management)
    - [Sub-Pod Aggregation](#126-sub-pod-aggregation)
13. [Shared Packages & Preferences](#13-shared-packages--preferences)

---

## 1. Core Philosophy

- Architecture is **deterministic**: given any feature or screen name, the location of its notifier (Pod), state, logic, actions, and widgets is always predictable.
- Inspired by clean architecture but **adaptable and pragmatic**.
- Unidirectional data flow: UI → Actions/Logic → Notifiers (Pods) → UI.
- UI components should be **highly modular**. Avoid monolithic widgets; extract components into their own files or focused private widgets.
- Prefer **Riverpod** (`flutter_riverpod`) using the **Pod structure** for state management, unless state is strictly ephemeral and local to a single widget (in which case `ValueNotifier` or local widget state is acceptable).
- AI tooling must check if a structural pattern already exists in canonical feature modules before inventing something new. Follow existing patterns consistently.

---

## 2. Widget Rules

### 2.1 Keep Widgets Small and Modular

Break large widgets into smaller, focused components. UI components must be modular. Extract components into dedicated files under the feature's `ui/widgets/` directory or `lib/shared/components/` if shared globally.

```dart
// Bad: monolithic build method
class ComplexWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('Title'),
          TextField(),
          ElevatedButton(onPressed: () {}, child: Text('Submit')),
        ],
      ),
    );
  }
}

// Good: decomposed modular widgets
class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});
  @override
  Widget build(BuildContext context) => const Text('Title');
}

class InputWidget extends StatelessWidget {
  const InputWidget({super.key});
  @override
  Widget build(BuildContext context) => const TextField();
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key, required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onPressed, child: const Text('Submit'));
}
```

### 2.2 Widget File vs. Private Widget Decision

- A widget deserves its own file in `widgets/` if it is **reusable or significant enough** to stand alone (e.g., `CourseCard`, `UserProfileHeader`, `SearchFilterBar`).
- If a widget is only used internally within a parent widget and is **too small or specific to justify its own file**, declare it as a **private widget** (`_PrivateWidget`) in the same file, below the parent widget.

```dart
// course_card.dart
class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.data});
  final CourseCardData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _CourseThumbnail(imageUrl: data.imageUrl),
        title: Text(data.title),
        subtitle: Text(data.tutorName),
      ),
    );
  }
}

// Private — highly specific sub-element
class _CourseThumbnail extends StatelessWidget {
  const _CourseThumbnail({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover),
    );
  }
}
```

### 2.3 Widget Models (Data Classes)

- **Public widgets** with **more than 2 non-action parameters** should receive their data through a dedicated immutable model class (using `Equatable` or standard immutable fields).
- The parameter name should consistently be `data`.
- **Private widgets** have no such restriction — they can accept individual parameters as appropriate.
- **Screens/Views** passed to a `GoRoute` should strictly accept one argument model or query parameters.

### 2.4 Use Specialist Widgets Over Generalist Ones

Always prefer the most specific widget for the job:
- Use `ColoredBox` or `DecoratedBox` instead of `Container` when only color or decoration is needed.
- Use `SizedBox` for fixed spacing or width/height constraints.
- Use `Padding` for whitespace padding only.
- Use `Align` or `Center` directly rather than nesting `Container(alignment: ...)`.

---

## 3. Code Documentation Standards

### 3.1 Simple Functions

Single-line triple-slash comment describing exactly what the function does:

```dart
/// Returns the formatted full name for the given user profile.
String getFullName(UserModel user) => '${user.firstName} ${user.lastName}';
```

### 3.2 Complex Functions with Helper Routines

For complex multi-step functions:
1. A **3-line ASCII separator** above it.
2. A **one-liner triple-slash comment** on the line directly after the separator.
3. Private helper routines placed directly below.

```dart
// ============================================================
// Validates and submits course update data
// ============================================================
/// Validates user input, formats requests, and dispatches to Api.
Future<bool> updateCourse() async {
  final validated = _validateFields();
  if (!validated) return false;
  return await _sendUpdate();
}

bool _validateFields() { ... }
Future<bool> _sendUpdate() async { ... }
```

### 3.3 Class-Level Comments

Every class, Pod, or mixin must have a brief doc comment explaining its responsibility:

```dart
/// Manages user authentication state, form controllers, and sign-in requests.
class SignInPod extends Notifier<SignInState> with TextEditingControllerFactoryMixin { ... }
```

---

## 4. Performance Optimization

- **`const` constructors everywhere possible.** Never instantiate non-const widgets if all arguments are compile-time constants.
- **Selective watching:** Prefer watching specific state properties or using `select` when only a sub-property triggers re-rendering.
- **Use `RepaintBoundary`** around heavily animated or custom-painted elements.
- **Lazy loading:** Always use `ListView.builder` or `SliverList` for lists and pagination.
- **Offload CPU-bound computations** using `compute()` or worker isolates.
- **Controller disposal:** Always dispose text controllers, focus nodes, and animation controllers in `ref.onDispose` or mixin teardowns.

---

## 5. Folder Structure Overview

```
lib/
├── app/                  ← Application setup, routing, themes, global config
│   ├── assets/           ← Generated asset accessors (flutter_gen)
│   ├── config/           ← Environment, flavors, base URLs
│   ├── constants/        ← Global app constants, strings, sizing
│   ├── routes/           ← GoRouter configuration and route definitions
│   ├── app.dart          ← Root MaterialApp.router widget
│   ├── app_provider.dart ← Global AppNotifier / app-level state
│   └── app_state.dart    ← Global AppState
├── core/                 ← Foundational shared utilities, base classes, enums
│   ├── base/             ← Mixins, extensions, helper utilities, base classes
│   ├── enums/            ← Global enum definitions
│   ├── utils/            ← UI utilities (toasts, dialogs) and misc helpers (Result)
│   └── core.dart         ← Core barrel file
├── data/                 ← Local persistence, caching, and storage drivers
│   ├── const_data/       ← Static seed or reference data
│   ├── drift/            ← Drift SQLite local database & DAOs
│   ├── shared_preferences/ ← SharedPreferences wrapper & typed accessors
│   ├── storage/          ← Secure storage & custom file storage
│   ├── app_paths.dart    ← App sandbox paths & directory helpers
│   └── shared_pref_keys.dart
├── network/              ← Remote networking, REST API, services
│   ├── extra/            ← Interceptors, auth session manager
│   ├── models/           ← Request and response DTOs
│   ├── src/              ← Domain-specific API services (auth, users, courses, etc.)
│   ├── api.dart          ← Primary Api singleton (Api.instance)
│   ├── core_api.dart     ← Low-level HTTP transport client
│   └── external_api.dart ← Third-party cloud services (AWS S3, etc.)
├── shared/               ← Reusable cross-feature UI design system components
│   ├── animations/       ← Transition animations & motion widgets
│   ├── components/       ← Reusable widgets (buttons, inputs, cards, dialogs)
│   ├── models/           ← Shared UI data models
│   ├── popups/           ← Bottom sheets, modals, toasts
│   └── styles/           ← Theme data, typography, color palettes
├── features/             ← Feature modules (screencentric & domain flows)
│   ├── activation/       ← Onboarding, auth (sign in, sign up, otp), account setup
│   ├── main/             ← Main navigation shells (student, tutor) & bottom tabs
│   ├── account/          ← User profile, settings, notifications, preferences
│   ├── browse/           ← Search, course discovery, tutor listings
│   ├── learning/         ← Course details, course dashboard, lessons, quizzes
│   ├── media/            ← Media playback (video/audio) and document viewer
│   ├── studio/           ← Tutor course creator / management studio
│   ├── billing/          ← Subscriptions, payment gateways, wallet transactions
│   ├── legal/            ← Terms of service, privacy policy
│   └── splash.dart       ← Splash screen
└── main.dart             ← Application entrypoint
```

---

## 6. lib/app

Handles app bootstrapping, routing, and global application-level state.

- **`app.dart`**: Defines `ScholarArkApp` consuming `appProvider` and `appRouter`.
- **`app_provider.dart`**: Declares `appProvider = NotifierProvider<AppNotifier, AppState>(AppNotifier.new);` managing theme modes, authentication status transitions, and connectivity.
- **`routes/app_router.dart`**: Declares `GoRouter` with redirects driven by `AuthSession.instance`.
- **`assets/`**: Auto-generated by `flutter_gen` into typed accessors (e.g., `AppAssets.icons...`). Never manually hardcode asset path strings.

---

## 7. lib/core

### 7.1 core/base

Holds core architectural extensions, mixins, and common helpers:
- **`extensions/src/extension_on_provider.dart`**: Riverpod extension methods (`read`, `watch`, `not`, `readX`, `watchX`, `notX`, `keepAliveFor`).
- **`mixins/text_editing_controller_factory_mixin.dart`**: Lifecycle-managed `TextEditingController` generation via `useTextEditingController()` and `disposeControllers()`.
- **`helpers/validators.dart`**: Shared email, password, and form validation utilities.
- **`helpers/formatters/`**: Date and string formatting helpers.

### 7.2 core/enums

Holds system-wide domain enumerations:
- `UserRole` (`student`, `tutor`, `admin`)
- Course difficulty levels, payment statuses, media types, etc.

### 7.3 core/utils

- **`misc/result.dart`**: Unified functional `Result<T>` or `ApiResult<T>` wrapper for safe execution without uncaught exceptions (`Result.tryRun`, `Result.tryRunAsync`).
- **`ui/nav_utils.dart`**: Safe navigation wrappers with context accessibility.
- **`ui/ui_utils.dart`**: Toast notifications, bottom sheet launchers, dialog display utilities.

---

## 8. lib/data

Responsible for local persistence and offline data access:
- **`drift/`**: Drift SQLite database for relational offline storage (courses, lessons, offline tracking).
- **`shared_preferences/shared_prefs.dart`**: Fast key-value persistence for flags, cached tokens, and theme settings.
- **`storage/`**: Secure storage (`flutter_secure_storage`) for sensitive auth tokens and cryptographic secrets.

---

## 9. lib/network

Centralizes all network communications using `kickin_network`:
- **`Api.instance`**: Unified entrypoint (`Api.instance.auth`, `Api.instance.users`, `Api.instance.courses`, `Api.instance.lessons`, `Api.instance.payments`).
- **`AuthSession.instance`**: Singleton holding current user session, tokens, and role information.
- **`extra/misc/token_interceptor.dart`**: Transparent JWT token refresh and session invalidation interceptor.
- **`models/`**: Strongly-typed request and response DTOs organized by domain.

---

## 10. lib/shared

Contains the global reusable UI design system:
- **`components/`**: Modular, atomic UI components (e.g., `AppButton`, `AppTextInput`, `AppDialog`, `CustomAppBar`).
- **`styles/`**: Colors, typography, decorations, and theme configuration.
- Shared widgets must remain completely independent of any specific feature Pod or state.

---

## 11. lib/features

Each feature directory represents a cohesive business or functional domain. Canonical reference implementations live in `activation`, `main`, `account`, `browse`, `learning`, and `studio`.

```
features/
└── <feature_name>/
    ├── logic/          ← Business logic, static use-cases, validators (no BuildContext)
    ├── providers/      ← Riverpod Pods, states, and extension part files
    └── ui/
        ├── actions/    ← UI-level action handlers & navigation callbacks (optional)
        ├── models/     ← UI-specific presentation models (optional)
        ├── screens/    ← Screen views (suffixed with View, e.g., SignInView)
        └── widgets/    ← Feature-specific modular widgets
```

### 11.1 UI Layer

- **Screens / Views (`screens/` or `views/`)**:
  - Always suffix screen widgets with `View` (e.g., `SignInView`, `EditProfileView`, `CourseDetailsView`).
  - Screen widgets extend `ConsumerWidget` or `ConsumerStatefulWidget`.
- **Widgets (`widgets/`)**:
  - Modular, reusable sub-components of the screen.
  - Large screens must be decomposed into multiple focused widgets in `widgets/`.
- **Actions (`actions/`)**:
  - UI interactions requiring `BuildContext` or navigation can be encapsulated in mixins or action helpers.

### 11.2 Logic Layer

- Contains pure Dart business logic, calculation, and multi-step orchestration.
- Logic classes or functions must not reference `BuildContext`.
- Methods should return `Result<T>` or model objects rather than throwing unhandled exceptions.

### 11.3 Providers / State Layer

All Riverpod state management lives under `providers/` using the **Pod structure**.

---

## 12. Riverpod State Pattern (Pod Structure)

The project strictly follows the **Pod Structure** for Riverpod state management.

### 12.1 Pod Definition & `me` Accessor

Every Pod defines a private top-level provider constant and exposes it publicly via a static `me` property on the Pod class:

```dart
// sign_in_pod.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholar_ark/core/base/base.dart';
import 'sign_in_state.dart';

part 'ext_on_sign_in_pod.dart';

final _signInProvider = NotifierProvider.autoDispose<SignInPod, SignInState>(
  SignInPod.new,
  name: 'SignInPod',
);

class SignInPod extends Notifier<SignInState> with TextEditingControllerFactoryMixin {
  /// Public accessor for the provider instance
  static final me = _signInProvider;

  @override
  SignInState build() {
    ref.onDispose(_dispose);
    addListeners();
    return const SignInState();
  }

  late final emailController = useTextEditingController();
  late final passwordController = useTextEditingController();

  void setLoading(bool value) => state = state.copyWith(isLoading: value);

  Future<bool> submit() async {
    setLoading(true);
    // ... API call
    setLoading(false);
    return true;
  }

  void _dispose() {
    removeListeners();
    disposeControllers();
  }
}
```

When arguments or family-like initialization is needed, use named constructors with factories:
```dart
final _verifyOtpProvider = NotifierProvider.autoDispose(
  () => VerifyOtpPod.create(arg: ''),
  name: 'VerifyOtpPod',
);

class VerifyOtpPod extends Notifier<VerifyOtpState> {
  static final me = _verifyOtpProvider;

  final String arg;
  VerifyOtpPod.create({required this.arg});
  ...
}
```

### 12.2 State Definition with Equatable

Every Pod has a corresponding `<name>_state.dart` declaring an immutable state class:

```dart
// sign_in_state.dart
import 'package:equatable/equatable.dart';

class SignInState extends Equatable {
  final bool isLoading;
  final bool isPasswordVisible;
  final bool canSubmit;
  final bool rememberMe;
  final String? errorMessage;

  const SignInState({
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.canSubmit = false,
    this.rememberMe = false,
    this.errorMessage,
  });

  SignInState copyWith({
    bool? isLoading,
    bool? isPasswordVisible,
    bool? canSubmit,
    bool? rememberMe,
    String? errorMessage,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      canSubmit: canSubmit ?? this.canSubmit,
      rememberMe: rememberMe ?? this.rememberMe,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isPasswordVisible,
    canSubmit,
    rememberMe,
    errorMessage,
  ];
}
```

### 12.3 Extension Part Files (`ext_on_*_pod.dart`)

To keep Pod classes lean and readable, auxiliary routines (listeners, input validation, secondary helper operations) are separated into a `part` file:

```dart
// In sign_in_pod.dart:
part 'ext_on_sign_in_pod.dart';

// In ext_on_sign_in_pod.dart:
part of 'sign_in_pod.dart';

extension ExtOnSignInPod on SignInPod {
  void _checkCanSubmit() {
    final valid = emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    if (state.canSubmit == valid) return;
    state = state.copyWith(canSubmit: valid);
  }

  void addListeners() {
    emailController.addListener(_checkCanSubmit);
    passwordController.addListener(_checkCanSubmit);
  }

  void removeListeners() {
    emailController.removeListener(_checkCanSubmit);
    passwordController.removeListener(_checkCanSubmit);
  }
}
```

### 12.4 Extension Helpers on Providers

Use the custom Riverpod extension helpers defined in `lib/core/base/extensions/src/extension_on_provider.dart`:

```dart
// Reading state
final state = MyPod.me.read(ref);       // WidgetRef
final state = MyPod.me.readX(ref);      // Ref (inside notifiers)

// Watching state
final state = MyPod.me.watch(ref);      // WidgetRef
final state = MyPod.me.watchX(ref);     // Ref

// Accessing the Notifier instance
final notifier = MyPod.me.not(ref);     // WidgetRef
final notifier = MyPod.me.notX(ref);    // Ref

// Watching the Notifier instance
final notifier = MyPod.me.watchNot(ref);
final notifier = MyPod.me.watchNotX(ref);

// Auto-caching / keep-alive
ref.keepAliveFor(const Duration(minutes: 5));
```

### 12.5 Controller Lifecycle Management

Use `TextEditingControllerFactoryMixin` to manage text editing controllers in Pods:
- Call `useTextEditingController()` to register controllers.
- Call `disposeControllers()` inside `ref.onDispose` to prevent memory leaks.

### 12.6 Sub-Pod Aggregation

When a top-level feature coordinates multiple sub-tabs or sub-features (e.g., `MainPod` managing tabs, or `ManageCoursePod` managing course sections), expose sub-providers directly on the parent Pod class as static properties:

```dart
class MainPod extends Notifier<MainState> {
  static final me = _mainProvider;

  // Sub-tab pod accessors
  static final homeTab = HomeTabPod.me;
  static final coursesTab = CoursesTabPod.me;
  static final tutorsTab = TutorsTabPod.me;
  static final profileTab = ProfileTabPod.me;
  ...
}
```

---

## 13. Shared Packages & Preferences

| Concern | Package | Pattern / Usage |
|---|---|---|
| State Management | `flutter_riverpod: ^3.3.2` | Pod Structure (`NotifierProvider`, `me` static accessor, `ext_on_*_pod.dart`) |
| Data Models | `equatable: ^2.0.8` | Immutable states, value equality via `props` and `copyWith` |
| Routing & Navigation | `go_router: ^17.3.0` | Declarative routing in `app_router.dart` |
| Local Storage | `drift: ^2.34.3` + `shared_preferences` + `kickin_storage` | Typed SQLite tables, key-value storage, secure storage |
| Networking | `kickin_network: ^0.0.3` | `Api.instance` modular REST client |
| Asset Management | `flutter_gen: ^5.12.0` | Type-safe generated assets in `lib/app/assets/` |
| Component Modularity | Native Flutter | Extract UI into focused files under `widgets/` |

---

## 14. AI Tooling & Contribution Guidelines

1. **Verify Existing Precedent**: Before generating new files or folder structures, inspect existing canonical modules (`activation/auth`, `main/student`, `account/profile`, `studio/manage_course`).
2. **Follow Riverpod Pod Pattern**: All new stateful features must use `Notifier<State>` or `AsyncNotifier<State>`, provide a static `me` accessor, use `ext_on_*_pod.dart` for auxiliary logic when needed, and maintain an immutable `*State` class.
3. **Modular Widgets**: Never output monolithic screens with inlined 500-line build methods. Extract distinct widgets into separate files.
4. **Maintain `cache_progress.md`**: Keep tracking progress, architecture updates, and notes for subsequent sessions in `cache_progress.md` at the project root.