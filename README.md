StablexDL
=========

Experiments with drawTiles based display list for Haxe NME.
Works for flash, html5, cpp and neko.


Test machine: Core i7 3.4GHz, GeForce 640, Unbuntu 12.04
------------------------------

Test results for examples/bunnies:

* cpp:        62`000 bunnies @ 60fps
* cpp:        130`000 bunnies @ 30fps
* html5:      4`200  bunnies @ 30fps
* flash -web: 1`100  bunnies @ 30fps

With `-notransform` conditional compilation flag:

* cpp:        140`000 bunnies @ 30fps
* flash -web: 21`000  bunnies @ 30fps
* html5:      4`500   bunnies @ 30fps

With `thread` flag (cpp only):

* 90`000 bunnies @ 57-60fps
* 210`000 bunnies @ 27-30fps