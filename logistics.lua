local util = require "util"

local logistics = {}

function logistics.save_logistic_layout(player, name)
    if not name or name == "" then
        player.print("New layout name cannot be nil or empty")
        return
    end
	
	if not check_player_has_character(player) then return end

    local slots = {}
    for i = 1, player.character.request_slot_count do
        local slot = player.get_personal_logistic_slot(i)
        if slot and slot.name then
            slots[i] = slot
        end
    end

    util.log('Saving current layout as ' .. name)
    global.layouts[name] = {
        slots = slots,
        slot_count = player.character.request_slot_count,
    }
end

function logistics.clear_logistic_layout(player)
	if not check_player_has_character(player) then return end
	

    for i = 1, player.character.request_slot_count do
        player.clear_personal_logistic_slot(i)
    end
end

function logistics.restore_logistic_layout(player, name)
	if not check_player_has_character(player) then return end

    logistics.clear_logistic_layout(player)
    local layout = global.layouts[name]
    if not layout then
        util.log("Invalid layout " .. name .. ", probably because of a stale GUI. Current global: " .. serpent.line(global))
        redraw_gui(player)
        return
    end
    for index, slot in pairs(layout.slots) do
        if not pcall(player.set_personal_logistic_slot, index, slot) then
            util.log('Ignoring unknown item ' .. slot.name)
        end
    end
end

function logistics.delete_logistic_layout(player, name)
    util.log('Deleting layout ' .. name)
    global.layouts[name] = nil
end

function logistics.rename_logistic_layout(from, to)
    global.layouts[from].renaming = false
    if from ~= to then
        global.layouts[to] = global.layouts[from]
        global.layouts[from] = nil
    end
end

function logistics.count_layouts()
    local num_layouts = 0
    for _, _ in pairs(global.layouts) do
        num_layouts = num_layouts + 1
    end
    return num_layouts
end

function check_player_has_character(player)
	if not player.character then
		util.log("You can only use this when you are controlling your character")
		return false
	end
	
	return true
end

return logistics
