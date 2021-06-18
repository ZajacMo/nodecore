-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local floodable = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.floodable then floodable[k] = true end
		end
	end)

function nodecore.fluidwander(name, gencheck, scandist)
	scandist = scandist or 5
	local function movesrc(pos, np, node, flowname, gen)
		minetest.set_node(np, node)
		minetest.get_meta(np):set_int("fluidgen_" .. name, gen + 1)
		minetest.set_node(pos, {name = flowname, param2 = 7})
	end
	return function(pos, node)
		local meta = minetest.get_meta(pos)
		local gen = meta:get_int("fluidgen_" .. name)
		if gencheck(pos, node, gen) then return end
		local miny = pos.y
		local maxy = pos.y
		local found = {}
		local attdist = 1/0
		local attract = {}
		local flowname = minetest.registered_items[node.name].liquid_alternative_flowing
		nodecore.scan_flood(pos, scandist, function(p)
				if p.y > maxy then return false end
				local nn = minetest.get_node(p).name
				if nn == node.name then return end
				if nn == flowname then
					if p.y > miny then return end
					if p.y == miny then
						found[#found + 1] = p
						return
					end
					miny = p.y
					found = {p}
				elseif floodable[nn] and p.y < maxy then
					local diff = vector.subtract(pos, p)
					local dsqr = vector.dot(diff, diff)
					if dsqr > attdist then return end
					if dsqr == attdist then
						attract[#attract + 1] = p
						return
					end
					attdist = dsqr
					attract = {p}
				end
			end)
		if #found < 1 then return end
		-- if miny == maxy and #attract > 0 then
		-- local na = nodecore.pickrand(attract)
		-- end
		movesrc(pos, nodecore.pickrand(found), node, flowname, gen)
	end
end
