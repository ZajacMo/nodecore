-- LUALOCALS < ---------------------------------------------------------
local nodecore, pairs, type
    = nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local function scantbl(t)
	for k, v in pairs(t) do
		if v == 0.5 then
			t[k] = 127/256
		elseif v == -0.5 then
			t[k] = -127/256
		elseif type(v) == "table" then
			scantbl(v)
		end
	end
end

nodecore.register_on_register_item(function(_, def)
		if def.type ~= "node" then return end
		if def.node_box and def.node_box.fixed then
			scantbl(def.node_box.fixed)
		end
	end)
