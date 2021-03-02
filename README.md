# Atomic Artillery Remote

Attempt to create a Quality of Life enhancement for 
[Atomic Artillery](https://github.com/sirdoombox/AtomicArtillery)

This is a second version that creates a custom ammunition type for Atomic Artillery shells,
which requires its own turret and its own targeting remote.

## What it does

When I have expensive Atomic Artillery Shells and use the remote, then I want to shoot the Atomic Artillery Shells.
I do not want some random artillery turret to shoot a simple shell into that large biter base.
On the other hand I do not want Atomic Artillery Shells to fire to kill the single stray worm.

This mod supports exactly this situation:
it defines a new set of items and a new ammunition type for the Atomic Artillery.
This gives you more control over the artillery, with two targeting remotes you can
place different target markers for "normal" Artillery and Atomic Artillery
(except for some bugs and edge cases, see below).

Unfortunately this also requires separate Turret building for the different kinds of
Artillery. It is no longer possible to interchange Artillery shells and
Atomic Artillery shells in the same Turret.

## Issues/Limitations

### Migrations

When you add this mod to an existing save game will disable all Artillery turrets and wagons
with Atomic artillery shells (because the ammo type no longer matches).

When you remove this mod all its entities are removed from the game.

### Unreliable

If no "plain" Artillery with ammo is in range, then the Atomic Artillery will
still fire on targets placed with the "Artillery targeting remote".

To my knowledge this should not be possible due to the different flare types,
selecting different ammo types, but there seems to be a precedence or fall-back mechanism(?)
Any help or advice with this would be appreciated.

### Targeting Radius in map mode

If an Atomic Artillery is in range, then the plain "Artillery targeting remote"
still shows the larger target radius (in map mode). 

### Graphics

This mod could use some graphics.
So far I created very simple item icons for the remote and a turret with a green dot,
in order to distinguish the atomic items in the inventory.
But there is no entity graphic for the placed turret, so the Artillery turrets
look the same and only a mouse-over will show the different entity names.
