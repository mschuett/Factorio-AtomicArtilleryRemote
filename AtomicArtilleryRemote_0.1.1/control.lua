require "util"

function aar_mod_init(event)
    -- ensure global state tables
    if not global.events then
        global.events = {}
    end
    if not global.turrets then
        global.turrets = {}
    end
end

function aar_log(message)
    -- helper function to log out debug info to file and game console
    game.write_file("aar_debug.log", message .. "\n", true)
    -- game.print(message)
end


function aar_get_turrets_in_range(player, position)
    -- finds all artillery turrets in artillery range of position
    -- distinguishes between turrets with atomic shells and turrets with plain shells
    -- returns two arrays
    
    -- thanks to Discord how to get the range.
    -- manual mode (with remote) seems to get 2.5 times the normal (automatic) range
    local artillery_range = game.item_prototypes["artillery-wagon-cannon"].attack_parameters.range
        * (1 + player.force.artillery_range_modifier) * 2.5
    -- aar_log(string.format("artillery range: %.2f * %.2f * %.2f = %.2f",
    --     game.item_prototypes["artillery-wagon-cannon"].attack_parameters.range,
    --     (1 + player.force.artillery_range_modifier),
    --     2.5,
    --     artillery_range))

    local all_turrets = player.surface.find_entities_filtered{
        name = ["artillery-turret",  "artillery-wagon"],
        force = "player",
        position = position,
        radius = artillery_range
    }

    if (not all_turrets) then
        -- no turrets in range
        return {}, {}
    end
    
    -- else: check for turrets with atomic shells
    aar_log(string.format("found %d artilleries in current range %.2f",
        #all_turrets, artillery_range))

    local atomic_turrets = {}
    local plain_turrets = {}
    for _, turret in pairs(all_turrets) do
        local dist = util.distance(position, turret.position)

        local t_shell = 0
        local t_atomic = 0
        if (turret.has_items_inside()) then
            t_shell = turret.get_item_count("artillery-shell")
            t_atomic = turret.get_item_count("atomic-artillery-shell")
        end
        
        local t_entity_string = string.format("%16s (%8d) @ (%5.1f, %5.1f) dist %6.1f: ",
            turret.name, turret.unit_number, turret.position.x, turret.position.y, dist)
        local t_status_string = string.format("active %s, stat %d, %d shells, %d atomic shells",
            turret.active, turret.status, t_shell, t_atomic)

        if (t_atomic > 0) then
            table.insert(atomic_turrets, turret)
        else
            table.insert(plain_turrets, turret)
        end
        aar_log(t_entity_string .. t_status_string)
    end
    return atomic_turrets, plain_turrets
end


function aar_on_player_used_capsule(event)
    -- main function: do something when the artillery remote is used

    -- is this for us?
    if (event.item.name ~= "artillery-targeting-remote") then
        return
    end

    -- basics
    local player = game.get_player(event.player_index)
    atomic_turrets, plain_turrets = aar_get_turrets_in_range(player, event.position)
    
    if (#atomic_turrets == 0) then
        aar_log("no turrets with atomic shells in range --> do nothing")
        -- game continues to shoot normal artillery shells
        return
    end
    
    -- else: atomic turrets in range => disable plain turrets
    local disabled_turrets = {}
    for _, turret in pairs(plain_turrets) do
        turret.active = false
        table.insert(disabled_turrets, turret)
    end

    -- first result: we disabled some turrets to let the "atomic turrets" fire.
    -- now we have to register an event to re-enable them later on,
    -- to do that we use the artillery flares at the target location

    -- check out the target flare(s)
    local target_flares = player.surface.find_entities_filtered{
        name = "artillery-flare",
        position = event.position
    }

    local registered_events = {}
    for _, flare in pairs(target_flares) do
        local event_reg_no = script.register_on_entity_destroyed(flare)
        table.insert(registered_events, event_reg_no)
        aar_log(string.format("found flare: %s @ %5.1f, %5.1f --> register event %d",
            flare.name, flare.position.x, flare.position.y, event_reg_no))
            
        -- multiple flares on the same location leads to problems,
        --> we get multiple event registrations for the same flare, but not all events might fire
        -- to prevent the whole situation we simply stop after the first flare
        -- 
        -- IMHO this is ok, because the double-click is an exception and it is not
        -- really important to correctly match the event ordering
        -- it is more important to re-enable all turrets and to keep the global state clean
        break
    end

    -- finally save global our state
    -- ensure global state tables
    if not global.events then
        global.events = {}
    end
    if not global.turrets then
        global.turrets = {}
    end
    
    -- per event: relevant turrets
    for _, event in pairs(registered_events) do
        event_str = tostring(event)
        global.events[event_str] = {}
        for _, turret in pairs(disabled_turrets) do
            table.insert(global.events[event_str], turret)
        end
    end

    -- per turrets: all outstanding events
    for _, turret in pairs(disabled_turrets) do
        turret_str = tostring(turret.unit_number)
        if not global.turrets[turret_str] then
            aar_log("create global.turrets[turret] for turret " .. turret_str)
            global.turrets[turret_str] = {}
        end
        for _, event in pairs(registered_events) do
            table.insert(global.turrets[turret_str], event)
        end
    end
    
    aar_log(string.format("resulting status: events %s turrets %s",
        aar_show_global_events(), aar_show_global_turrets()))
end

function table_removebyKey(tab, val)
    for i, v in ipairs (tab) do 
        if (v == val) then
          tab[i] = nil
        end
    end
end

function aar_entity_destroyed(event)
    -- event handler when flare is destroyed
    local reg_number = event.registration_number
    event_str = tostring(reg_number)
    aar_log(string.format("flare destroy event %d", reg_number))
    
    if not global.events[event_str] then
        error("invalid mod state, missing event registration number " .. event_str)
    end

    local turretlist = global.events[event_str]
    global.events[event_str] = nil
    -- todo: leaves emtpy entries in table

    for _, turret in pairs(turretlist) do
        turret_str = tostring(turret.unit_number)
        -- remove event from per-turrent list
        util.remove_from_list(global.turrets[turret_str], reg_number)
        aar_log(string.format("removed turret %s and event %d",
            turret_str, reg_number))

        if (#global.turrets[turret_str] == 0) then
            -- no more events for turret -> re-activate
            turret.active = true
            aar_log("enabled turret " .. turret_str)
            global.turrets[turret_str] = nil
        end
    end

    aar_log(string.format("remaining status: events %s turrets %s",
        aar_show_global_events(), aar_show_global_turrets()))
end


-- global event listener registrations:
script.on_init(aar_mod_init)
script.on_event(defines.events.on_player_used_capsule, aar_on_player_used_capsule)
script.on_event(defines.events.on_entity_destroyed, aar_entity_destroyed)


-- console commands to help with debugging/introspection
function aar_show_global_events()
    if not global.events then
        return "not initialized"
    end

    -- we store LuaEntity refs for turrets, so serpent will not work for userdata

    local event_list = {}
    for event_number, turretlist in pairs(global.events) do
        local turret_ids = {}
        for _, turret in pairs(turretlist) do
            table.insert(turret_ids, turret.unit_number)
        end
        event_list[event_number] = turret_ids
        -- table.insert(event_list, {event_number, turret_ids})
    end
    return game.table_to_json(event_list)
end

function aar_show_global_turrets()
    if not global.turrets then
        return "not initialized"
    end
    
    return serpent.line(global.turrets)
end

commands.add_command("aar_events", "Show module's global events table", function()
    game.print(aar_show_global_events())
end)

commands.add_command("aar_turrets", "Show module's global turrets table", function()
    game.print(aar_show_global_turrets())
end)
