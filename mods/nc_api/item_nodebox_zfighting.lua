-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, type
    = minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local function scantbl(t, adjto)
	for k, v in pairs(t) do
		if v == 0.5 then
			t[k] = adjto
		elseif v == -0.5 then
			t[k] = -adjto
		elseif type(v) == "table" then
			scantbl(v, adjto)
		end
	end
end

local function clone(t) return minetest.deserialize(minetest.serialize(t)) end

nodecore.register_on_register_item(function(_, def)
		if def.type ~= "node" then return end
		if def.node_box and def.node_box.fixed then
			def.collision_box = def.collision_box or clone(def.node_box)
			def.selection_box = def.selection_box or clone(def.node_box)
			scantbl(def.node_box.fixed, def.z_fight_win and 129/256 or 127/256)
		end
	end)
