# Atomic Artillery Remote

Attempt to create a Quality of Life enhancement for 
[Atomic Artillery](https://github.com/sirdoombox/AtomicArtillery)

It does not add any new items or recipes, it only changes the
behaviour of the Artillery Remote in combination with Atomic Artillery Shells.

## What it does

When I have expensive Atomic Artillery Shells and use the remote, then I want to shoot the Atomic Artillery Shells.
I do not want some random artillery turret to shoot a simple shell into that large biter base.

This mod supports exactly this situation:
When the remote is used the mod checks all artillery turrets in range.
If any turret in range has Atomic Artillery Shells, then all the other turrets are disabled for a short time, so that only the "right" turret may fire.

## Issues

It works reasonably well with turrets, but I could not get it to work with Artillery Wagons:
The mod does find the wagon, and it disables it, and then the wagon shoots anyway.

## Comments on the Lua code

Be careful, this is my first attempt writing Lua.
So please save often, save early, and expect some bugs.

At first I tried to define an additional `ammo-type` and a special kind of remote.
That did not work, but that is the reason it is still called "Atomic Artillery Remote" and all my functions use the name prefix `aar_`.

I had some problems with numeric table indices (e.g. `global.events[5]`).
Lua's table insert/remove operations would treat the table as an array and shift the elements around.
In order to treat the tables as hashmaps I convert the indices to strings (e.g. `global.events["5"]`).
I would love to learn a better solution.
