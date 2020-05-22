local inspect = require "inspect"

local factoriact = {}

local function assign_children(props, children)
    local props_copy = {}
    for k, v in pairs(props) do
        props_copy[k] = v
    end
    props_copy.children = children or {}
    return props_copy
end

function factoriact.create_element(component, props, children)
    props = props or {}
    return {
        component = component,
        props = assign_children(props, children)
    }
end

function factoriact.render_element(elem)
    local render_result

    local elem_type = type(elem)
    if elem_type == 'string' or elem_type == 'number' then
        -- asked to render a literal string or number
        return fr.e(
            'label',
            {
                caption = component
            }
        )
    elseif elem_type == 'table' then
        local component = elem.component
        local comp_type = type(component)

        if comp_type == 'function' then
            -- asked to render a component function
            return factoriact.render_element(component(elem.props))
        elseif comp_type == 'string' then
            -- asked to render a native GUI component
            for i, child in pairs(elem.props.children) do
                elem.props.children[i] = factoriact.render_element(child)
            end
            return elem
        end
    end
end

function factoriact.render(elem, gui_root)
end

fr = factoriact -- for easy debugging
pt = function(t) print(inspect(t)) end
factoriact.e = factoriact.create_element

local function InnerFrame(props)
    return fr.e(
        'frame',
        {
            innerframe = true
        },
        props.children
    )
end

local function DoubleFrame(props)
    return fr.e(
        'frame',
        props,
        {
            fr.e(
                InnerFrame,
                {},
                props.children
            )
        }
    )
end


elem = fr.e(
    DoubleFrame,
    {
        direction = "horizontal"
    },
    {
        fr.e(
            'button',
            {
                style = "one"
            }
        ),
        "Hello",
        fr.e(
            'button',
            {
                style = "three"
            }
        )
    }
)
pt(elem)
pt(fr.render_element(elem))













return factoriact
