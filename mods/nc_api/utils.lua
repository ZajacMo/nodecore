-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, type
    = ipairs, math, minetest, nodecore, pairs, type
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

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

function nodecore.extend_node(name, func)
	local orig = minetest.registered_nodes[name]
	local copy = {}
	for k, v in pairs(orig) do copy[k] = v end
	copy = func(copy, orig) or copy
	minetest.register_node(":" .. name, copy)
end

function nodecore.fixedbox(...) return {type = "fixed", fixed = {...}} end
