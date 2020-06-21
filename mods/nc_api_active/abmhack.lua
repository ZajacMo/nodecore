-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, tonumber
    = math, minetest, nodecore, pairs, tonumber
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local ratio = math_floor(tonumber(minetest.settings:get(nodecore.product
			.. "_abm_launder_ratio")) or 4)
if ratio < 2 then return end

local defer = {}
for i = 1, (ratio - 1) do defer[i] = {} end

local proc = 0
minetest.register_globalstep(function()
		proc = (proc % (ratio - 1)) + 1
		local batch = defer[proc]
		print(proc)
		if #batch > 0 then
			local getnode = minetest.get_node
			for _, v in pairs(batch) do
				local node = getnode(v[1])
				if node.name == v[2] then v[3](v[1], node) end
			end
			defer[proc] = {}
		end
	end)

local bucket = 0
local oldreg = minetest.register_abm
function minetest.register_abm(def, ...)
	local oldact = def.action
	def.action = function(pos, node)
		bucket = (bucket + 1) % ratio
		if bucket == 0 then
			return oldact(pos, node)
		else
			local batch = defer[bucket]
			batch[#batch + 1] = {pos, node.name, oldact}
		end
	end
	return oldreg(def, ...)
end

nodecore.register_limited_abm = function(...) return minetest.register_abm(...) end
