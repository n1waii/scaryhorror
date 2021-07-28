return  {
    shallowcopy = function(original)
        local orig_type = type(original)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in pairs(original) do
                copy[orig_key] = orig_value
            end
        else 
            copy = original
        end
        return copy
    end,

    cast = function(original, castFunction)
        local new = {}
        for k,v in ipairs(original) do
            new[k] = castFunction(v)
        end
        return new
    end
}