require("mod-gui")

function save_logistic_layout(player, name)
    if not name or name == "" then
        player.print("name cannot be nil or empty")
        return
    end

    local slots = {}
    for i = 1, player.character_logistic_slot_count do
        local slot = player.get_personal_logistic_slot(i)
        if slot and slot.name then
            slots[i] = slot
        end
    end

    global.layouts[name] = {
        slots = slots,
        slot_count = player.character_logistic_slot_count,
    }
end

function clear_logistic_layout(player)
    for i = 1, player.character_logistic_slot_count do
        player.clear_personal_logistic_slot(i)
    end
    player.character_logistic_slot_count = 0
end

function restore_logistic_layout(player, name)
    clear_logistic_layout(player)
    local layout = global.layouts[name]
    player.character_logistic_slot_count = layout.slot_count
    for index, slot in pairs(layout.slots) do
        player.set_personal_logistic_slot(index, slot)
    end
end

function delete_logistic_layout(player, name)
    global.layouts[name] = nil
end

function create_button(player)
    if not player.character then
        player.print("player has no character")
        return
    end

    local flow = mod_gui.get_button_flow(player)
    local button = flow.toggle_saved_logistics_layouts
    if button then return end

    logistic_robot = game.item_prototypes['logistic-robot']
    if logistic_robot then
        flow.add{
            type = "sprite-button",
            name = "toggle_saved_logistics_layouts",
            sprite = "item/logistic-robot",
            style = mod_gui.button_style,
            tooltip = "Toggle saved logistics layouts frame",
            number = 3,
        }
    else
        flow.add{
            type = "button",
            name = "toggle_saved_logistics_layouts",
            caption = "Saved Logistics Layouts",
            style = mod_gui.button_style,
            tooltip = "Toggle saved logistics layouts frame",
        }
    end
end

function toggle_frame(player)
    local flow = mod_gui.get_frame_flow(player)
    local frame = flow.saved_logistics_frame

    if frame then
        frame.destroy()
        return
    end

    frame = flow.add{
        type = "frame",
        name = "saved_logistics_frame",
        caption = "Saved Logistics Layouts",
        style = mod_gui.frame_style,
        direction = "vertical",
    }
end

function repaint_frame(player)
    local flow = mod_gui.get_frame_flow(player)
    local frame = flow.saved_logistics_frame

    if not frame then return end

    frame.clear()
    local layout_table = frame.add{
        type = "table",
        column_count = 3,
    }
    for layout_name, layout in pairs(global.layouts) do
        layout_table.add{
            type = "sprite-button",
            sprite = "utility/export_slot",
            tooltip = "Restore saved layout",
            name = "restore_saved_layout/" .. layout_name,
        }
        layout_table.add{
            type = "sprite-button",
            sprite = "utility/trash",
            tooltip = "Delete saved layout",
            name = "delete_saved_layout/" .. layout_name,
        }
        layout_table.add{
            type = "label",
            caption = layout_name,
        }
    end
    frame.add{
        type = "line",
        direction = "horizontal",
    }
    frame.add{
        type = "textfield",
        name = "new_layout_name",
        tooltip = "The name for this new saved layout"
    }
    frame.add{
        type = "button",
        name = "save_current_logistics_layout",
        caption = "Save current logistics layout"
    }
    frame.add{
        type = "button",
        name = "clear_current_logistics_layout",
        caption = "Clear current logistics layout"
    }
end

function on_button_click(event)
    local player = game.players[event.player_index]

    local name = event.element.name
    local _, _, restore_layout_name = string.find(name, "restore_saved_layout/(%a+)")
    local _, _, delete_layout_name = string.find(name, "delete_saved_layout/(%a+)")

    if name == "toggle_saved_logistics_layouts" then
        toggle_frame(player)
    elseif name == "save_current_logistics_layout" then
        local new_layout_name = mod_gui.get_frame_flow(player).saved_logistics_frame.new_layout_name.text
        save_logistic_layout(player, new_layout_name)
    elseif name == "clear_current_logistics_layout" then
        clear_logistic_layout(player)
    elseif restore_layout_name then
        restore_logistic_layout(player, restore_layout_name)
    elseif delete_layout_name then
        delete_logistic_layout(player, delete_layout_name)
    else
        return
    end

    repaint_frame(player)
end

function setup()
    global.layouts = global.layouts or {}
    for _, player in pairs(game.players) do
        create_button(player)
    end
end

script.on_init(setup)
script.on_event(defines.events.on_gui_click, on_button_click)

remote.add_interface("bluegistics", {
    clear_globals=function() global.layouts = {}; repaint_frame(game.player) end,
    reinit=setup,
})
