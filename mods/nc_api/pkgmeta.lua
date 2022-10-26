return {
	title = function(alpha)
		return "NodeCore" .. (alpha and " ALPHA" or "")
	end,
	desc = function(alpha)
		return alpha
		and "Early-access edition of NodeCore with latest features (and maybe bugs)"
		or "Minetest's top original voxel game about emergent mechanics and exploration"
	end
}
