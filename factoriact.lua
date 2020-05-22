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
        render_result = fr.e(
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
            render_result = factoriact.render_element(component(elem.props))
        elseif comp_type == 'string' then
            -- asked to render a native GUI component
            local rendered_children = {}
            for i, child in pairs(elem.props.children) do
                rendered_children[i] = factoriact.render_element(child)
            end
            elem.props.children = rendered_children
            render_result = elem
        end
    end

    return render_result
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
        fr.e(
            'button',
            {
                style = "two"
            }
        ),
        fr.e(
            'button',
            {
                style = "three"
            }
        )
    }
)
pt(elem)
pt(fr.render_element(elem, 5))













return factoriact
