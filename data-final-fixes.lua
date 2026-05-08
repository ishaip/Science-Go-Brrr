-- Every Research Costs One
-- Sets all technology research costs to 1 cycle with 1 of each required science pack

function calculate(name, technology)
    -- Skip trigger-based technologies or those without proper unit definitions
    if technology.research_trigger ~= nil then
        return
    elseif technology.unit == nil or technology.unit.ingredients == nil then
        return
    end

    -- Set research count to 1 (or use formula for infinite research)
    if technology.unit.count_formula then
        -- For infinite research with formulas, we keep the formula but cap minimum at 1
        technology.unit.count_formula = 'max(1, ' .. technology.unit.count_formula .. ')'
        log(name .. " : formula-based infinite research adjusted")
    elseif technology.unit.count then
        -- For normal research, set count to 1
        local original_count = technology.unit.count
        technology.unit.count = 1
        log(name .. " : count set to 1 (was " .. original_count .. ")")
    end

    -- Set all ingredient amounts to 1
    for _, ingredient in pairs(technology.unit.ingredients) do
        local pack_name = ingredient[1] or ingredient.name
        local original_amount = ingredient[2] or ingredient.amount or 1

        -- Set amount to 1 for all ingredients
        if ingredient[2] then
            ingredient[2] = 1
        end
        if ingredient.amount then
            ingredient.amount = 1
        end
        if not ingredient[2] and not ingredient.amount then
            ingredient[2] = 1
        end

        log(name .. " : " .. (pack_name or "?") .. " amount set to 1 (was " .. original_amount .. ")")
    end
end

-- Process ALL technologies
for name, technology in pairs(data.raw.technology) do
    xpcall(calculate, function(err)
        log("Error in technology " .. name .. ": " .. err)
    end, name, technology)
end

log("Every Research Costs One: All technologies adjusted!")
