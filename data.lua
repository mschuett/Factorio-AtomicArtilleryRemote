-- data.lua
--
-- decided to put everything into one file so we can use local variables
-- could be split up later...

local turret_name = "atomic-artillery-turret"
local remote_item_name = "atomic-artillery-targeting-remote"
local remote_icon_path = "__AtomicArtilleryRemote__/graphics/icons/".. remote_item_name ..".png"
local turret_icon_path = "__AtomicArtilleryRemote__/graphics/icons/".. turret_name ..".png"
local flare_name = "atomic-artillery-flare"
local ammo_type_name = "atomic-artillery"
local gun_name = "atomic-wagon-cannon"

-- new ammo category
data:extend({{
    type = "ammo-category",
    name = ammo_type_name
}})

-- change in-place (not sure if this is safe)
local atomicArtilleryShell = table.deepcopy(data.raw["ammo"]["atomic-artillery-shell"])
local ammo_type = atomicArtilleryShell.ammo_type
ammo_type.category = ammo_type_name
atomicArtilleryShell.ammo_type = ammo_type
data:extend({atomicArtilleryShell})

-- new gun
local atomicGun = table.deepcopy(data.raw["gun"]["artillery-wagon-cannon"])
atomicGun.name = gun_name
local atomicGun_params = atomicGun.attack_parameters
atomicGun_params.ammo_category = ammo_type_name
atomicGun.attack_parameters = atomicGun_params
data:extend({atomicGun})

-- new artillery turret item
local atomicTurretItem = table.deepcopy(data.raw["item"]["artillery-turret"])
atomicTurretItem.name = turret_name
atomicTurretItem.place_result = turret_name
atomicTurretItem.icon = turret_icon_path
atomicTurretItem.icon_size = 64
data:extend({atomicTurretItem})

-- new artillery turret entity
local atomicTurret = table.deepcopy(data.raw["artillery-turret"]["artillery-turret"])
atomicTurret.name = turret_name
atomicTurret.minable.result = turret_name
atomicTurret.gun = gun_name
data:extend({atomicTurret})

-- new artillery turret - recipe
local atomicTurretRecipe = table.deepcopy(data.raw["recipe"]["artillery-turret"])
atomicTurretRecipe.enabled = true
atomicTurretRecipe.name = turret_name
atomicTurretRecipe.result = turret_name
atomicTurretRecipe.ingredients = {{"artillery-turret",1},{"repair-pack",1}}
data:extend({atomicTurretRecipe})

-- new artillery flare (= map target marker)
local atomicFlare = table.deepcopy(data.raw["artillery-flare"]["artillery-flare"])
atomicFlare.name = flare_name
atomicFlare.icon = remote_icon_path
atomicFlare.icon_size = 32
atomicFlare.map_color = {r=0.5, g=1, b=0}
atomicFlare.pictures = {{
    filename = "__core__/graphics/shoot-cursor-green.png",
    priority = "low",
    width = 258,
    height = 183,
    frame_count = 1,
    scale = 1,
    flags = {"icon"}
}}
atomicFlare.shot_category = ammo_type_name
data:extend({atomicFlare})

-- new remote item
local atomicRemoteItem = table.deepcopy(data.raw["capsule"]["artillery-targeting-remote"])
atomicRemoteItem.name = remote_item_name
atomicRemoteItem.icon = remote_icon_path
atomicRemoteItem.icon_size = 32
atomicRemoteItem.capsule_action = {
    type = "artillery-remote",
    flare = flare_name
}
data:extend({atomicRemoteItem})

-- new remote recipe
local atomicRemoteRecipe = table.deepcopy(data.raw["recipe"]["artillery-targeting-remote"])
atomicRemoteRecipe.enabled = true
atomicRemoteRecipe.name = remote_item_name
atomicRemoteRecipe.result = remote_item_name
atomicRemoteRecipe.ingredients = {{"artillery-targeting-remote",1},{"repair-pack",1}}
data:extend({atomicRemoteRecipe})

-- technology requirements
table.insert(data.raw["technology"]["atomic-bomb"].effects,{type="unlock-recipe",recipe=remote_item_name})
table.insert(data.raw["technology"]["atomic-bomb"].effects,{type="unlock-recipe",recipe=turret_name})
