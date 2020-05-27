require "mod-gui"
local logistics = require "logistics"
local util = require "util"

function create_button(player)
    if not player.character then
        util.log("player has no character")
        return
    end

    local flow = mod_gui.get_button_flow(player)
    local button = flow.toggle_saved_logistics_layouts
    if button then return end

    local button
    logistic_robot = game.item_prototypes['logistic-robot']
    if logistic_robot then
        button = flow.add{
            type = "sprite-button",
            name = "toggle_saved_logistics_layouts",
            sprite = "item/logistic-robot",
            style = mod_gui.button_style,
            tooltip = "Toggle saved logistics layouts frame",
            number = logistics.count_layouts(),
        }
    else
        button = flow.add{
            type = "button",
            name = "toggle_saved_logistics_layouts",
            caption = "Saved Logistics Layouts",
            style = mod_gui.button_style,
            tooltip = "Toggle saved logistics layouts frame",
        }
    end
end

function recreate_button(player)
    local flow = mod_gui.get_button_flow(player)
    local button = flow.toggle_saved_logistics_layouts
    if button then
        button.destroy()
    end
    create_button(player)
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
    repaint_frame(player)
end

function repaint_frame(player)
    local flow = mod_gui.get_frame_flow(player)
    local frame = flow.saved_logistics_frame

    if not frame then return end

    frame.clear()
    local layout_table = frame.add{
        type = "table",
        column_count = 4,
    }
    for layout_name, layout in util.sorted_pairs(global.layouts) do
        layout_table.add{
            type = "sprite-button",
            sprite = "utility/export_slot",
            style = "green_icon_button",
            tooltip = "Restore saved layout",
            name = "restore_saved_layout/" .. layout_name,
        }

        layout_table.add{
            type = "sprite-button",
            sprite = "utility/trash",
            style = "red_icon_button",
            tooltip = "Delete saved layout",
            name = "delete_saved_layout/" .. layout_name,
        }

        if layout.renaming then
            layout_table.add{
                type = "sprite-button",
                sprite = "utility/check_mark",
                style = "tool_button",
                tooltip = "Rename saved layout",
                name = "rename_saved_layout/" .. layout_name,
            }
            layout_table.add{
                type = "textfield",
                text = layout_name,
                name = "layout_new_name/" .. layout_name,
                tooltip = "The new name for this saved layout"
            }
        else
            layout_table.add{
                type = "sprite-button",
                sprite = "utility/rename_icon_small",
                style = "tool_button",
                tooltip = "Rename saved layout",
                name = "rename_saved_layout/" .. layout_name,
            }
            layout_table.add{
                type = "label",
                caption = layout_name,
            }
        end
    end

    frame.add{
        type = "line",
        direction = "horizontal",
    }

    local new_name_input = frame.add{
        type = "textfield",
        name = "new_layout_name",
        tooltip = "The name for this new saved layout"
    }
    new_name_input.style.horizontally_stretchable = "on"

    local save = frame.add{
        type = "button",
        name = "save_current_logistics_layout",
        caption = "Save current logistics layout"
    }
    save.style.horizontally_stretchable = "on"

    local clear = frame.add{
        type = "button",
        name = "clear_current_logistics_layout",
        caption = "Clear current logistics layout"
    }
    clear.style.horizontally_stretchable = "on"
end

function redraw_gui(player)
    recreate_button(player)
    repaint_frame(player)
end

function on_button_click(event)
    local player = game.players[event.player_index]

    local name = event.element.name
    local _, _, restore_layout_name = string.find(name, "restore_saved_layout/(%a+)")
    local _, _, delete_layout_name = string.find(name, "delete_saved_layout/(%a+)")
    local _, _, rename_layout_name = string.find(name, "rename_saved_layout/(%a+)")

    if name == "toggle_saved_logistics_layouts" then
        toggle_frame(player)
    elseif name == "save_current_logistics_layout" then
        local new_layout_name = mod_gui.get_frame_flow(player).saved_logistics_frame.new_layout_name.text
        logistics.save_logistic_layout(player, new_layout_name)
    elseif name == "clear_current_logistics_layout" then
        logistics.clear_logistic_layout(player)
    elseif restore_layout_name then
        logistics.restore_logistic_layout(player, restore_layout_name)
    elseif delete_layout_name then
        logistics.delete_logistic_layout(player, delete_layout_name)
    elseif rename_layout_name then
        local layout = global.layouts[rename_layout_name]
        util.log(serpent.line(layout))
        if layout.renaming then
            util.log('event.element.name: ' .. event.element.name)
            util.log('event.element.parent.name: ' .. event.element.parent.name)
            local layout_new_name_textbox = event.element.parent["layout_new_name/" .. rename_layout_name]
            util.log('layout_new_name_textbox.name: ' .. layout_new_name_textbox.name)
            util.log('layout_new_name_textbox.text: ' .. layout_new_name_textbox.text)
            logistics.rename_logistic_layout(rename_layout_name, layout_new_name_textbox.text)
        else
            layout.renaming = true
        end
    else
        return
    end

    redraw_gui(player)
end

function on_gui_confirmed(event)
    local player = game.players[event.player_index]

    local name = event.element.name
    local _, _, rename_layout_name = string.find(name, "layout_new_name/(%a+)")

    if name == "new_layout_name" then
        local new_layout_name = mod_gui.get_frame_flow(player).saved_logistics_frame.new_layout_name.text
        logistics.save_logistic_layout(player, new_layout_name)
    elseif rename_layout_name then
        logistics.rename_logistic_layout(rename_layout_name, event.element.text)
    else
        return
    end

    redraw_gui(player)
end

function setup()
    global.layouts = global.layouts or {}
    for _, player in pairs(game.players) do
        redraw_gui(player)
    end
end

script.on_init(setup)
script.on_configuration_changed(setup)
script.on_event(defines.events.on_gui_click, on_button_click)
script.on_event(defines.events.on_gui_confirmed, on_gui_confirmed)

remote.add_interface("bluegistics", {
    clear_layouts=function() global.layouts = {}; redraw_gui(game.player) end,
    set_layouts=function(layouts) global.layouts = layouts; redraw_gui(game.player) end,
    reinit=setup,
    debug=function(d) global.__debug__ = d end,
})
