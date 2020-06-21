-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, tonumber
    = minetest, nodecore, pairs, tonumber
-- LUALOCALS > ---------------------------------------------------------

local defer = {}

minetest.register_globalstep(function()
		for _, v in pairs(defer) do v() end
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
			local nn = node.name
			defer[#defer + 1] = function()
				node = minetest.get_node(pos)
				if node.name == nn then return oldact(pos, node) end
			end
		end
	end
	return minetest.register_abm(def)
end
