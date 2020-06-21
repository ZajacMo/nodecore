-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, tonumber
    = minetest, nodecore, pairs, tonumber
-- LUALOCALS > ---------------------------------------------------------

local defer = {}

minetest.register_globalstep(function()
		for _, v in pairs(defer) do
			local node = minetest.get_node(v[1])
			if node.name == v[2] then v[3](v[1], node) end
		end
		defer = {}
	end)

local ratio = tonumber(minetest.settings:get(nodecore.product .. "_abm_launder_ratio")) or 4
function nodecore.register_limited_abm(def)
	local count = 0
	local oldact = def.action
	def.action = function(pos, node)
		count = count + 1
		if count % ratio == 1 then
			return oldact(pos, node)
		else
			defer[#defer + 1] = {pos, node.name, oldact}
		end
	end
	return minetest.register_abm(def)
end
