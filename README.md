# Flutter E-Commerce Product Listing App

A modern **Flutter-based e-commerce application** that fetches products from a remote API and displays them in a clean, animated product grid.
The app includes **category filtering, debounced search, cart management, and a smooth iOS-style UI experience.**

---

# 1. Framework Choice

This project is built using **Flutter**.

### Why Flutter?

Flutter was chosen because it provides:

* **Single codebase for multiple platforms** (Android, iOS, Web, Desktop)
* **Fast UI rendering** using the Skia graphics engine
* **Rich widget ecosystem**
* **Hot reload** for rapid development
* **High performance** close to native apps

Additionally, Flutter enables building **beautiful and highly customizable UI** with smooth animations, which was important for this application.

State management is handled using **Provider**, which is lightweight, easy to scale, and suitable for small to medium sized applications.

---

# 2. How to Run the App from Scratch

Follow these steps to run the project locally.

## Step 1: Install Flutter

Download and install Flutter:

https://flutter.dev/docs/get-started/install

Verify installation:

```
flutter doctor
```

---

## Step 2: Clone the Repository

```
git clone https://github.com/akshatbudholiya/sofrik_app_dev_assignment_ecomm_task
cd flutter-ecommerce-app
```

---

## Step 3: Install Dependencies

```
flutter pub get
```

---

## Step 4: Run the App

Connect a device or start an emulator, then run:

```
flutter run
```

The application will launch on your device.

---

# 3. Features

* Product listing fetched from API
* Category filtering
* Debounced product search
* Cart management
* Animated product grid
* iOS-style large header UI
* Error handling and loading states
* Responsive UI

---

# 4. Project Architecture

The app follows a **simple scalable architecture**:

```
lib/
 ├── models/
 ├── providers/
 ├── services/
 ├── screens/
 ├── widgets/
 └── main.dart
```

### Architecture Pattern

The project loosely follows **MVVM principles**:

* **Model** → Product data model
* **View** → UI screens and widgets
* **ViewModel / Provider** → Business logic and state management

---

# 5. Known Limitations

Some limitations of the current implementation include:

1. No persistent storage for the cart (cart resets after app restart)
2. No user authentication
3. No backend database integration
4. Search only filters by title and category
5. Pagination is not implemented for large datasets

These were intentionally simplified to keep the project focused on UI, architecture, and state management.

---

# 6. What I Would Improve With More Time

With additional development time, the following improvements could be implemented:

### Performance Improvements

* Implement **API pagination / lazy loading**
* Add **caching for product images**
* Optimize rebuilds using **Selector / Riverpod**

### Feature Improvements

* Add **product detail page**
* Implement **checkout flow**
* Add **wishlist functionality**
* Implement **user authentication**

### UX Enhancements

* Animated **add-to-cart interactions**
* **Search suggestions**
* **Product sorting options**
* **Skeleton loaders for better loading experience**

### Architecture Improvements

* Migrate state management to **Riverpod or Bloc**
* Introduce **clean architecture layers**
* Add **unit tests and widget tests**

---

# 7. Dependencies Used

Main packages used in the project:

* provider → state management
* http → API calls
* cached_network_image → optimized image loading
* flutter_rating_bar → product ratings UI
* badges → cart badge indicator

---

# 8. Author

Akshat Narayan Budholiya

Mobile App Developer (Flutter)

---

# 9. License

This project is created for **technical evaluation and learning purposes**.
