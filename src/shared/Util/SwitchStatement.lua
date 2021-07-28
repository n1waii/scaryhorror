return function(str)
	return function(dict)
		local case = dict[str] or dict["Default"]
        if case then
			case()
		end
	end
end