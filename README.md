# SHEIN — Flutter Web Clone (DEPI Training Task)

A SHEIN-style e-commerce storefront built with **Flutter Web** and **Firebase**,
implemented in two days as a DEPI training task. It covers the basic
e-commerce services end to end: browsing/searching a catalog, product
details, a Firestore-backed cart, a wishlist, email/password auth, and
checkout that writes real orders to Firestore.

> Demo/training project: Firestore rules are intentionally open so the app
> can seed its demo catalog anonymously on first run. Do not deploy as-is
> (see `firestore.rules`).

## Features

| Area | What works |
| --- | --- |
| Home | Hero banner, category strip, New In / Best Sellers / Sale sections (all Firestore-driven) |
| Catalog | Group pages (`/catalog/women`), search (`/catalog/all?q=shirt`), category-chip filters, empty states |
| Product | Image carousel, price/discount/rating, size & color pickers, quantity stepper |
| Cart | Firestore-backed per-user cart, realtime badge, quantity updates, remove, summary |
| Wishlist | Firestore-backed per-user wishlist, save/remove from product pages, wishlist page |
| Auth | Email/password sign-up & sign-in, session persistence across reloads, friendly mapped errors |
| Checkout | Delivery-address form, order written to Firestore, cart cleared, redirect to My Orders with a success banner |
| Orders | Per-user order history (`/orders?placed=1` shows the confirmation banner) |

## Architecture

**Feature-first MVVM** with `flutter_bloc` (one Cubit per feature):

```
lib/
├── main.dart                  # Firebase init, path-URL strategy, semantics, Bloc observer
├── app.dart                   # MaterialApp + theme + router
├── core/
│   ├── router/app_router.dart # go_router route table (below)
│   ├── theme/                 # AppColors / AppTheme
│   ├── utils/                 # auth_gate (guest prompt), FirebaseErrorMapper, Fmt, BlocObserver
│   └── widgets/               # shared UI: ProductCard, PriceText, RatingStars, page states…
├── data/
│   ├── models/                # ProductModel, CartItemModel, OrderModel (Firestore maps ⇄ objects)
│   ├── repositories/          # auth / product / cart / wishlist / order repositories
│   └── seeding/product_seed.dart  # 52 demo products (generated from dummyjson.com demo data)
└── features/<feature>/
    ├── view/                  # screens (Flutter widgets only)
    └── viewmodel/             # Cubit + state per feature
```

**Data flow:** Screen → Cubit (ViewModel) → Repository → Firebase.
Cubits self-subscribe to `authStateChanges`, so cart/wishlist/orders switch
user context automatically on sign-in/out.

**Firestore layout:**

| Path | Contents |
| --- | --- |
| `products/{id}` | catalog, seeded on first run (`ensureSeeded()` writes 52 docs if empty) |
| `carts/{uid}/items/{productId__size}` | per-user cart lines (transaction-based add) |
| `wishlists/{uid}/items/{productId}` | per-user wishlist |
| `orders/{id}` | per-user orders (uid-filtered, newest first) |
| `users/{uid}` | profile (name, email, createdAt) |

**Routes** (path-URL strategy — real URLs, no `#`):

`/` · `/login` · `/signup` · `/catalog/<group>?q=` · `/product/<id>` ·
`/cart` · `/wishlist` · `/checkout` · `/orders?placed=1`

Guests can browse everything; cart/wishlist/checkout actions open a sign-in
prompt (`core/utils/auth_gate.dart` + `SignInPrompt`).

## Verification guide

### Prerequisites

- Flutter SDK `^3.13.4` (web enabled)
- A Firebase project wired via `flutterfire configure`
  (`lib/firebase_options.dart` is generated and already committed for this task)

### 1. Static analysis + unit tests

```bash
flutter analyze   # No issues found
flutter test      # 20 tests: ProductCard/PriceText/RatingStars widgets,
                  # catalog group+filter logic, Firebase error mapping
```

### 2. Build

```bash
flutter build web   # → build/web
```

### 3. End-to-end verification

The full user flows (guest browsing → sign-up → cart → checkout → orders)
were verified end to end in headless Chromium against the real Firebase
backend, driving the built app through its accessibility tree. The E2E
toolchain and suites live outside this repository and are not distributed
with it.

### 4. Manual run

```bash
flutter run -d chrome     # dev — or serve build/web with any static server
```

First run seeds the catalog (52 products) into Firestore automatically.

## Project notes

- `.zcode/` is local tooling config and must never be pushed to GitHub.
- `firestore.rules` are development-open on purpose; tighten before any real
  deployment (require `request.auth != null` for writes).
