require("mod-gui")

function save_logistic_layout(player, name)
    if not name or name == "" then
        player.print("name cannot be nil or empty")
        return
    end

    local layout = {}
    for i = 1, player.character_logistic_slot_count do
        local slot = player.get_personal_logistic_slot(i)
        if slot and slot.name then
            layout[i] = slot
        end
    end

    global.layouts[name] = layout
    repaint_frame(player)
end

function clear_logistic_layout(player)
    for i = 1, player.character_logistic_slot_count do
        player.clear_personal_logistic_slot(i)
    end
end

function restore_logistic_layout(player, layout)
    clear_logistic_layout(player)
    for index, slot in pairs(layout) do
        player.set_personal_logistic_slot(index, slot)
    end
end

function create_button(player)
    if not player.character then
        player.print("player has no character")
        return
    end

    mod_gui.get_button_flow(player).add{
        type = "button",
        name = "toggle_saved_logistics_layouts",
        caption = "Saved Logistics Layouts",
        style = mod_gui.button_style,
    }
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
    repaint_frame(frame)
end

function repaint_frame(player)
    local flow = mod_gui.get_frame_flow(player)
    local frame = flow.saved_logistics_frame

    if not frame then return end

    frame.clear()
    for name, layout in pairs(global.layouts) do
        frame.add{
            type = "button",
            caption = name,
            name = name,
        }
    end
    frame.add{
        type = "line",
        direction = "horizontal",
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
    local name = event.element.name
    local player = game.players[event.player_index]
    local saved_layout_to_restore = global.layouts[name]

    if name == "toggle_saved_logistics_layouts" then
        toggle_frame(player)
    elseif name == "save_current_logistics_layout" then
        save_logistic_layout(player, "franktest")
    elseif name == "clear_current_logistics_layout" then
        clear_logistic_layout(player)
    elseif saved_layout_to_restore then
        restore_logistic_layout(player, saved_layout_to_restore)
    end
end

function setup()
    global.layouts = global.layouts or {}
    for _, player in pairs(game.players) do
        create_button(player)
    end
end

script.on_init(setup)
script.on_event(defines.events.on_gui_click, on_button_click)
