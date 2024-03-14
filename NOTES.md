## Version 1.1
**New Features:**
* Added new built-in methods for turtle navigation
* Added a location bookmarking system
* Added a shell interface for the library
  * Type `it` if using the datapack, or `iturtle` if using the pastebin

**New Methods:**  

&nbsp;&nbsp;&nbsp;See the [documentation](https://github.com/w00tyd00d/iturtle-cc/wiki) for more information.
* `registerLocation`
* `unregisterLocation`
* `getLocation`
* `getAllLocations`
* `navigateLocal`
* `navigatePath`
* `navigateToPoint`
* `navigateToLocation`



<br>

## Version 1.0.1
**Bug Fixes:**
* Turtle facing dirction much less prone to desyncing when program is terminated early
* `shiftLeft` and `shiftRight` will now properly return a total execution count of 0 instead of `nil` if given a `count` of 0

<br>

## Version 1.0
* Initial release.
