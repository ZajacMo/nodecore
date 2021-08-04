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

function nodecore.fluidwander(name, gencheck, movedist, scandist)
	movedist = movedist or 2
	scandist = scandist or 8
	local function movesrc(pos, np, node, flowname, gen)
		minetest.set_node(np, node)
		minetest.get_meta(np):set_int("fluidgen_" .. name, gen + 1)
		minetest.set_node(pos, {name = flowname, param2 = 7})
		nodecore.dnt_set(pos, "fluidwander_" .. name)
	end
	return function(pos, node)
		local meta = minetest.get_meta(pos)
		local gen = meta:get_int("fluidgen_" .. name)
		if gencheck(pos, node, gen) then return end

		-- Search for nearby flowing nodes; these are the only
		-- nodes the source may be moved into.
		local miny = pos.y
		local maxy = pos.y
		local found = {}
		local attdist = 1/0
		local attract = {}
		local flowname = minetest.registered_items[node.name].liquid_alternative_flowing
		nodecore.scan_flood(pos, movedist, function(p)
				if p.y > maxy then return false end
				local nn = minetest.get_node(p).name
				if nn == node.name then return end
				if nn ~= flowname then return false end
				if p.y > miny then return end
				if p.y == miny then
					found[#found + 1] = p
					return
				end
				miny = p.y
				found = {p}
			end)
		if #found < 1 then return end

		-- If a place is found where the node can move downward, go immediately.
		if miny < maxy and #found > 0 then
			return movesrc(pos, nodecore.pickrand(found), node, flowname, gen)
		end

		-- If our only options are on the same level, search again to find
		-- a place where we would be able to flow down if our flow reached.
		-- This is interpeting the terrain as "subtly sloped" toward the
		-- hole allowing the fluid to find it.
		nodecore.scan_flood(pos, scandist, function(p)
				if p.y > maxy then return false end
				local nn = minetest.get_node(p).name
				if nn == node.name then return end
				if nn ~= flowname and not floodable[nn] then return false end
				if p.y < maxy then
					local diff = vector.subtract(p, pos)
					diff.y = 0
					local dsqr = vector.dot(diff, diff)
					if dsqr > attdist then return end
					if dsqr == attdist then
						attract[#attract + 1] = p
						return false
					end
					attdist = dsqr
					attract = {p}
					return false
				end
			end)

		-- If no hole was found, terrain is level, wander randomly.
		if #attract < 1 then
			return movesrc(pos, nodecore.pickrand(found), node, flowname, gen)
		end

		-- Pick the flowing node that's closest to the down-hole.
		local picked = nodecore.pickrand(attract)
		local bestpos
		local bestdsqr
		for i = 1, #found do
			local p = found[i]
			local diff = vector.subtract(p, picked)
			local dsqr = vector.dot(diff, diff)
			if (not bestdsqr) or (dsqr < bestdsqr) then
				bestdsqr = dsqr
				bestpos = p
			end
		end
		return movesrc(pos, bestpos, node, flowname, gen)
	end
end

function nodecore.register_fluidwandering(name, nodenames, interval, gencheck, movedist, scandist)
	local labelname = "fluidwander_" .. name
	nodecore.register_dnt({
			name = labelname,
			nodenames = nodenames,
			time = interval,
			action = nodecore.fluidwander(name, gencheck, movedist, scandist)
		})
	minetest.register_abm({
			label = labelname,
			interval = interval,
			chance = 1,
			nodenames = nodenames,
			action = function(pos)
				return nodecore.dnt_set(pos, labelname)
			end
		})
end
