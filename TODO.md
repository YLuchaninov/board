## TODO

* setup painter for connections
* to types of connection: straight, smoothed
* select connection
* separate `canvas.dart` and `painter.dart` to several abstractions for refactoring 
* Make item anchor point or alignment for stick to grid functionality
* Add time to animation in stick to grid functionality
* programmable scale anchor point move to center of view port from the start
* to add scrolling rules
* resize item example   
* to make license

## FIX

* stick to grid in dropping case
* first connections paint after loading
* small jitter when dragging a item(dragging anchor) (possible solution to use PreferredSizeWidget instead calculation of anchor size, or check item pointer solution)
* board drop point when scale of feedback not equivalent to the 1
* change logic of switching between selection by tap & longPress
* connections over items & menus
* check connections with stick to grid functionality

## CHECK

* connection & stick to grid functionality
* macOS browser dragging between different dpi screens(flutter issue)
* null safety solutions in whole project(refactoring)
