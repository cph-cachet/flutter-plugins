## 4.0.0

* changed to `background_locator_2` since the old `background_locator` is no longer maintained.
* upgrade of Android SDK level.
* small refactor to plugin and example app.

## 3.0.1

* **BREAKING** The plugin no longer support asking for location permissions. This is better handled at the application level. See the example app for how this can be done.
* upgrade to `background_locator: ^1.6.6`.
* cleanup and adding the `permission_handler` in example app
* added description of new location permission in Android 11 to README

## 2.0.0

* update to null-safety
* using a singleton as `LocationManager()` to access the location manager.

## 1.0.3

* small update to new `BackgroundLocator.registerLocationUpdate` API
* upgrade to `background_locator` v. 1.4.0

## 1.0.2

* upgrade to `background_locator` v. 1.2.2
* support for setting `accuracy`
* misc docs update

## 1.0.1+4

* Formatting

## 1.0.1+3

* Downgraded background_locator to 1.1.10+1

## 1.0.1+2

* Addressed static analysis error
* Recreated example with a new name

## 1.0.1+1

* Addressed a static analysis error

## 1.0.0

* Initial release
