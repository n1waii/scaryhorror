-- simple interface implementation
-- author: alphexus 

local Interface = {}
Interface.__index = Interface
Interface.__type = "Interface"

local Errors = {
	[0] = function(...) return error(("Expected interface value for property '%s'"):format(...)) end,
	[1] = function(...) return error(("Unknown property '%s'"):format(...)) end,
	[2] = function(...) return error(("Expected property '%s' to be of type '%s'. Got '%s' instead"):format(...)) end,
	[3] = function(...) return error(("Missing property '%s'"):format(...)) end
}


-- static methods
function Interface:Value(dataType, optional)
	return setmetatable({
		DataType = dataType,
		Optional = optional or false,
	}, {
		__index = function(t, k)
			if k == "type" then
				return "InterfaceValue"
			end
		end,
	})
end

-- object methods 
function Interface:Create(t)
	local optionals = {}
	local requireds = {}
	
	for name, interfaceValue in pairs(t) do
		if not (interfaceValue.type == "InterfaceValue") then
			Errors[0](name)
		end
		
		if interfaceValue.Optional then
			optionals[name] = interfaceValue
		else
			requireds[name] = interfaceValue
		end
	end

	return setmetatable({
		Props = t,
		Requireds = requireds,
		Optionals = optionals
	}, Interface)
end

function Interface:GetRequireds()
	return self.Requireds
end

function Interface:GetOptionals()
	return self.Optionals
end

function Interface:Compare(supposedInterface, strict)
	local alike = true
	for name, value in pairs(supposedInterface) do
		if not self.Props[name] then
			alike = false
			if strict then Errors[1](name) end 
		end

		if not (typeof(value) == self.Props[name].DataType) then
            alike = false
			if strict then Errors[2](name, self.Props[name].DataType, typeof(value)) end
		end
	end

	for name, interfaceValue in pairs(self:GetRequireds()) do
		if not supposedInterface[name] then
            alike = false
			if strict then Errors[3](name) end
		end	
	end
	
	return alike
end

function Interface:Implement(supposedInterface)	
	return self:Compare(supposedInterface, true) and supposedInterface
end

return Interface