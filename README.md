# Atomic Artillery Remote

This is an enhancement for [Atomic Artillery](https://github.com/sirdoombox/AtomicArtillery).
It creates a custom ammunition type for Atomic Artillery shells, which requires its own turret and its own targeting remote.

## Why

When I have expensive Atomic Artillery Shells and use the remote, then I want to shoot the Atomic Artillery Shells.
I do not want some random artillery turret to shoot a simple shell into that large biter base.
On the other hand I do not want Atomic Artillery Shells to fire to kill the single stray worm.

## How it works

This mod defines a ammunition type for the Atomic Artillery and duplicates
the Artillery entities (turret, wagon, and targeting remote) to shoot Atomic shells.

This gives you more control over the artillery, with two targeting remotes you can
place different target markers for "normal" Artillery and Atomic Artillery.

Unfortunately this also requires separate Turret building for the different kinds of
Artillery. It is no longer possible to interchange Artillery shells and
Atomic Artillery shells in the same Turret.

I did not try to change any balancing, just like in [Atomic Artillery](https://github.com/sirdoombox/AtomicArtillery)
the entities have the same cost as in the base game, so only the ammunition is expensive.

## Limitations

### Graphics

This mod could use some graphics.

So far I created very simple item icons for the remote and a turret with a green dot,
in order to distinguish the atomic items in the inventory.

There is no entity graphic for the placed turrets or wagons, so these
look the same and only a mouse-over will show the different entity names.

### Migrations

When you add this mod to an existing save game will disable all Artillery turrets and wagons
with Atomic artillery shells (because the ammo type no longer matches).

When you remove this mod all its entities are removed from the game.

### Auto-fire

Atomic artillery has the same "automatic" behaviour as plain artillery;
it will fire on every enemy worm or spawner in range.

## Screenshots

Just to get a quick impression of the entities.

![Screenshot with plain and atomic artillery turrets](images/turrets.png?raw=true "artillery turrets")

![Screenshot for Atomic artillery wagon](images/wagon.png?raw=true "Atomic artillery wagon")

![Screenshot for Atomic artillery turret recipe](images/turret-recipe.png?raw=true "Atomic artillery turret recipe")
