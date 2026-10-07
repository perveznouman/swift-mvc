# MVC: Users, Favourites & Weather (UIKit + Core Data)

Open `MVC.xcodeproj`, run on an iPhone simulator (iOS 16+). No third-party dependencies.

## Screens
1. **Users**: list from `jsonplaceholder.typicode.com/users` (name, username, email). Swipe to favourite.
2. **Favourites**: read purely from Core Data, so it works offline.
3. **User detail**: avatar (pravatar.cc), name, username, email, phone, website, address. Star button toggles favourite.
4. **Weather**: tap the address. Uses the user's `geo.lat/lng` with the Open-Meteo API (no key).

## Offline behaviour
Favouriting stores all user fields + avatar bytes. Opening the weather screen for a favourite saves the last report; if the network fails, that cached report is shown with an "Offline" banner.

## Where each MVC role lives
| Role | Files |
|------|-------|
| **Model** | `Models/` (User, Weather), `Services/` (APIClient, UserService, WeatherService, ImageLoader), `Persistence/` (Core Data stack, `FavoritesStore`) |
| **View** | `Views/` (UserCell, DetailRowView, StateView) |
| **Controller** | `Controllers/` (one view controller per screen + tab bar) |

## MVC observations (to compare with the later patterns)
- Controllers call services and the store directly and decide what to show. That is why they grow large.
- Dependencies are singletons (`FavoritesStore.shared`, ...), so controllers are hard to unit test. MVVM and Clean add dependency injection.
- `NotificationCenter` (`.favoritesDidChange`) keeps screens in sync; other patterns replace this with bindings, presenters, or a store.
- Formatting (`"\(Int(temp))°C"`, date parsing) lives in the controller. MVVM moves it to a view model.
