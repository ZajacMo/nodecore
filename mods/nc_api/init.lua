-- LUALOCALS < ---------------------------------------------------------
local dofile, ipairs, math, minetest, nodecore, pairs, rawset, type
    = dofile, ipairs, math, minetest, nodecore, pairs, rawset, type
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore = nodecore or {}
rawset(_G, "nodecore", nodecore)
for k, v in pairs(minetest) do
	if type(v) == "function" then
		-- Late-bind in case minetest methods overridden.
		nodecore[k] = function(...) return minetest[k](...) end
	else
		nodecore[k] = v
	end
end

function nodecore.mkreg()
	local t = {}
	local f = function(x) t[#t + 1] = x end
	return f, t
end

function nodecore.pickrand(tbl, weight)
	weight = weight or function() end
	local t = {}
	local max = 0
	for k, v in pairs(tbl) do
		local w = weight(v) or 1
		if w > 0 then
			max = max + w
			t[#t + 1] = {w = w, v = v}
		end
	end
	if max <= 0 then return end
	max = math_random() * max
	for i, v in ipairs(t) do
		max = max - v.w
		if max <= 0 then return v.v end
	end
end

function nodecore.fixedbox(...) return {type = "fixed", fixed = {...}} end

local path = minetest.get_modpath(modname)

dofile(path .. "/node_on_register.lua")

dofile(path .. "/node_drop_in_place.lua")
dofile(path .. "/node_falling_repose.lua")
dofile(path .. "/node_alternate_loose.lua")
dofile(path .. "/node_group_visinv.lua")

dofile(path .. "/action_node_pummel.lua")
