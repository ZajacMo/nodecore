-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local cache = {}

local function findfirst(i, func)
	local fdi = nodecore.facedirs[i]
	for j = 0, i do
		if i == j or func(fdi, nodecore.facedirs[j]) then
			return j
		end
	end
end

local function getlut(name)
	local def = minetest.registered_nodes[name]
	if not def then return end
	local func = def.nc_param2_equivalent
	if not func then return end
	local lut = {}
	for i = 1, 23 do lut[i] = findfirst(i, func) end
	lut[0] = findfirst(0, func)
	for i = 0, 23 do
		if lut[i] ~= i then return lut end
	end
end

local function param2_canonical(node, param2)
	local name = node.name

	local lut = cache[name]
	if lut == nil then
		lut = getlut(name) or false
		cache[name] = lut
	end
	if lut == false then return node end

	param2 = param2 or node.param2 or 0

	-- Support for colorfacedir and similar
	local hibits = 0
	if param2 > 23 then
		hibits = math_floor(param2 / 32) * 32
		param2 = (param2 % 32) % 24
	end

	param2 = (lut[param2] or 0) + hibits
	if node.param2 == param2 then return node end
	return {
		name = node.name,
		param = node.param,
		param2 = param2
	}
end

nodecore.param2_canonical = param2_canonical

for k in pairs({
		add_node = true,
		set_node = true,
		swap_node = true
	}) do
	local oldfunc = minetest[k]
	minetest[k] = function(pos, node, ...)
		return oldfunc(pos, param2_canonical(node), ...)
	end
end
