Description
-----------
This is a really basic astrophysical simulation.

Running
-------
Run it with

	$ love AstroSim

and see what happens.

Controls
--------
SPACEBAR - pause/resume simulation
c - toggle debug mode (on by default)
v - invert gravity
x - toggle a wall around the viewport
CTRL - change current tool
a, q - increase/decrease simulation speed, this has an effect on the simulation accuracy
s, w - change bounciness, this pretty much only works when planets don't remove comets
d, e - change maximum speed of objects
f, r - change the graviational constant

Tools
-----
Attractor - attract and repel objects, use left and right mouse buttons to attract and repel, respectively
Spawner - spawn comets

Class.lua
---------
A python-inspired lua class library, doesn't have the more advanced concepts, though.

Util.lua
--------
Includes a few helper classes like Color, Vector2f and List.
Also has a few helper functions like gfx.drawCircle and gfx.drawLine which use love's drawing functions with vectors and cursor.getPosition to get the cursor's position as a vector.

License
-------
This project is MIT licensed, refer to COPYING for more information.
