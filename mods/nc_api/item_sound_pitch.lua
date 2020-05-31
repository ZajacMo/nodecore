-- LUALOCALS < ---------------------------------------------------------
local nodecore, pairs
    = nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local soundadj = {
	nc_optics_glassy = -3,
	nc_lode_annealed = -3,
	nc_lode_tempered = -3
}
local toolgroups = {
	cracky = true,
	thumpy = true,
	choppy = true,
	crumbly = true,
	snappy = true,
	scratchy = true
}

nodecore.register_on_register_item(function(_, def)
		if def.type ~= "node" then return end
		local grp = def.groups
		if not grp then return end
		local snd = def.sounds
		if (not snd) or snd.no_level_pitch then return end
		local level = 0
		for k in pairs(toolgroups) do
			local l = grp[k]
			if l and l > level then level = l end
		end
		if level <= 0 then return end
		for _, v in pairs(snd) do
			local a = v.name and soundadj[v.name] or 0
			v.pitch = (v.pitch or 1) * (1 + 0.1 * level + a)
		end
		snd.no_level_pitch = true
	end)
