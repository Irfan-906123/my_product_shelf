# My Product Shelf

A small Flutter app (Android) to browse products, save favourites, edit a
profile and send a demo "add product" request. Built for the Flutter intern
two-day assignment.

## Setup

1. Install Flutter (Dart SDK 3.13 or newer) and connect an Android phone or
   start an emulator.
2. In the project folder run:

   ```
   flutter pub get
   flutter run
   ```

3. To build the debug APK:

   ```
   flutter build apk --debug
   ```

   The file is created at `build/app/outputs/flutter-apk/app-debug.apk`.

The app needs internet for the product list and the demo request. It uses the
DummyJSON API:

- `GET https://dummyjson.com/products?limit=12`
- `POST https://dummyjson.com/products/add`

## Project structure

```
lib/
  main.dart                      app start, providers
  models/product.dart            Product model (fromJson / toJson)
  providers/
    favourites_provider.dart     saved products (ChangeNotifier)
    profile_provider.dart        display name (ChangeNotifier)
  services/
    api_service.dart             GET and POST requests
    storage_service.dart         shared_preferences read / write
  screens/
    main_shell.dart              bottom navigation with 3 tabs
    home_screen.dart             product list, search, refresh
    saved_screen.dart            saved products
    profile_screen.dart          avatar, photo picker, display name
    add_product_screen.dart      demo POST form
  widgets/
    product_card.dart            one product row
    status_view.dart             empty / error / no-results view
```

## Completed features

**Home**
- Loads 12 products from the API: image, title, category, price, save button.
- Greeting with the saved display name and a "+ Add" button.
- Local search by title, with a "no products match" state.
- Pull-to-refresh (the list is replaced, so items are never duplicated).
- Loading, empty and error states. The error state has a Retry button.

**Saved**
- Shows the saved products from the same provider as Home.
- "N saved" chip, and a count badge on the Saved tab that is visible from Home.
- Tapping "Saved" on a card removes it. Both tabs update immediately.
- Empty state: "No saved products yet" with a "Browse products" button.

**Profile**
- Avatar placeholder (initials or a person icon) with a camera button on top.
- Choose a photo from the gallery with `image_picker`. Cancelling the picker
  keeps the existing photo.
- Edit and save the display name. Shows "Profile saved".

**Add product**
- Opens from the "+ Add" button on Home.
- Validation under the fields: title at least 3 characters, price greater
  than zero.
- Sends a POST request with JSON `title` and numeric `price`.
- The button changes to "Sending..." and is disabled during the request, so
  a double tap sends only one request.
- Success: "Demo request successful" with the returned product ID.
- Failure: a red box with the reason. The input is kept so the user can
  try again.

**Local storage**
- The display name and the saved products are kept with `shared_preferences`
  and are loaded again after a full app restart.
- Saved products are stored as a JSON list with `id`, `title`, `price` and
  `thumbnail`, so titles and prices are available offline.

**Error handling**
- Non-success status codes, no internet, timeouts (10 seconds) and invalid
  responses are turned into a friendly message (`ApiException`).
- Broken image URLs show a placeholder icon.

## Where each Flutter concept is used

### Provider

| What | Where |
|---|---|
| Providers are created | `main.dart` (`MultiProvider` with `Favourites` and `ProfileProvider`) |
| `watch` (listening UI) | `product_card.dart` (is this product saved?), `saved_screen.dart` (list and count), `home_screen.dart` (greeting name), `profile_screen.dart` (avatar initials) |
| `Consumer` (listening UI) | `main_shell.dart` (count badge on the Saved tab) |
| `read` (action callbacks) | `product_card.dart` (save / remove button), `profile_screen.dart` (Save profile button, and once in `initState` to fill the name field) |

Favourites are kept only in the `Favourites` provider. There is no second copy
in `setState`.

### setState (local UI state)

| Screen | State |
|---|---|
| `main_shell.dart` | selected tab |
| `home_screen.dart` | products, loading flag, error text, search text |
| `profile_screen.dart` | selected photo preview, saving flag, "Profile saved" message |
| `add_product_screen.dart` | sending flag, returned id, error text |

### initState

- `home_screen.dart`: starts the one-time product load. The API call is never
  made inside `build`.
- `profile_screen.dart`: creates the name controller with the saved name.
- `add_product_screen.dart`: lifecycle log only.

### dispose

- `home_screen.dart`: disposes the search controller.
- `profile_screen.dart`: disposes the name controller.
- `add_product_screen.dart`: disposes the title and price controllers.

### mounted check after await

Every `setState` that comes after an `await` first checks `if (!mounted) return;`
(`home_screen.dart`, `profile_screen.dart`, `add_product_screen.dart`). This
avoids the setState-after-dispose error when the user leaves the screen while
a request is still running.

### Lifecycle logs and their order

`HomeScreen` and `AddProductScreen` log `initState`, `build` and `dispose`
with `debugPrint`. `AddProductScreen` is the easiest one to watch:

1. Tap "+ Add": `AddProductScreen: initState`, then `AddProductScreen: build`.
2. Tap "Send request": `AddProductScreen: build` is logged again for every
   `setState`.
3. Press back: `AddProductScreen: dispose`.

So the order is: `initState` runs once when the State object is created,
`build` runs right after it and again on every `setState` or provider change,
and `dispose` runs once when the screen is removed for good.

`HomeScreen` lives inside an `IndexedStack`, so switching tabs does not
dispose it. Its `dispose` only runs when the whole app is closed.

### Layout

- `Row` + `Column` + `Expanded`: `product_card.dart` (details in a Column,
  price and action in a Row), `home_screen.dart` (Column for the screen,
  Expanded for the list).
- `Stack` + `Positioned`: saved badge over the product image
  (`product_card.dart`) and camera button over the avatar
  (`profile_screen.dart`).
- The Profile and Add product screens are scrollable, so the open keyboard
  does not cause an overflow.

## Known issues

- The profile photo is not saved. It resets after an app restart (optional in
  the assignment).
- Saved products loaded from storage have no category, because only id, title,
  price and thumbnail are stored.
- Pull-to-refresh works only while the product list is visible. In the error
  state, use the Retry button.
- The product added with the demo request is not shown on Home, because
  DummyJSON does not really save it.

## Outside help and generated code

- I used Claude Code (an AI coding assistant) while building this app. It
  generated or helped write `storage_service.dart`, `profile_provider.dart`,
  `profile_screen.dart`, `add_product_screen.dart`, the POST method in
  `api_service.dart`, the storage code in `favourites_provider.dart` and
  `main.dart`, and this README. I went through the code step by step and can
  explain and change it.
- Official docs: DummyJSON products API, and the pub.dev pages for `provider`,
  `http`, `image_picker` and `shared_preferences`.
