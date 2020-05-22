local inspect = require "inspect"

local factoriact = {}

function factoriact.create_element(component, props, children)
    props = props or {}
    children = children or {}
    return {
        component = component,
        props = props,
        children = children,
    }
end

function factoriact.render_element(elem)
    local elem_type = type(elem)
    if elem_type == 'string' or elem_type == 'number' then
        -- asked to render a literal string or number
        return fr.e(
            'label',
            {
                caption = elem
            }
        )
    elseif elem_type == 'table' then
        local component = elem.component
        local comp_type = type(component)
        if comp_type == 'function' then
            -- asked to render a component function
            return factoriact.render_element(component(elem.props, elem.children))
        elseif comp_type == 'string' then
            -- asked to render a native GUI component
            for i, child in pairs(elem.children) do
                elem.children[i] = factoriact.render_element(child)
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

local function InnerFrame(props, children)
    return fr.e(
        'frame',
        {
            innerframe = true
        },
        children
    )
end

local function DoubleFrame(props, children)
    return fr.e(
        'frame',
        props,
        {
            fr.e(
                InnerFrame,
                {},
                children
            )
        }
    )
end

local elem = fr.e(
    DoubleFrame,
    {
        direction = "horizontal",
    },
    {
        fr.e(
            'button',
            {
                style = "one"
            }
        ),
        3,
        "Hello",
    }
)
pt(fr.render_element(elem))













return factoriact
