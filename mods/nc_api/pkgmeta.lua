return {
	title = function(alpha)
		return "NodeCore" .. (alpha and " ALPHA" or "")
	end,
	desc = function(alpha)
		return alpha
		and "Early-access edition of NodeCore with latest features (and maybe bugs)"
		or "Discover and invent in a surreal, unsympathetic world of cubes, patterns, and abstractions."
	end
}
