-- LUALOCALS < ---------------------------------------------------------
local nodecore, pairs, type
    = nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local ratio = 127/128
nodecore.z_fight_ratio = ratio

local function scantbl(t)
	local u = {}
	for k, v in pairs(t) do
		if v == 0.5 then
			u[k] = ratio / 2
		elseif v == -0.5 then
			u[k] = -ratio / 2
		elseif type(v) == "table" then
			u[k] = scantbl(v)
		else
			u[k] = v
		end
	end
	return u
end

nodecore.register_on_register_item(function(_, def)
		if def.type ~= "node" then return end
		if def.node_box and def.node_box.fixed then
			def.collision_box = def.collision_box or def.node_box
			def.selection_box = def.selection_box or def.node_box
			def.node_box = scantbl(def.node_box)
		end
	end)
