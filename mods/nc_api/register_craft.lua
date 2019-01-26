-- LUALOCALS < ---------------------------------------------------------
local error, ipairs, math, minetest, nodecore, pairs, table, type
    = error, ipairs, math, minetest, nodecore, pairs, table, type
local math_floor, table_insert
    = math.floor, table.insert
-- LUALOCALS > ---------------------------------------------------------

local old_place = minetest.item_place_node

local recipes = {}
function nodecore.register_craft(recipe)
	if type(recipe.nodes) ~= "table" then
		error "missing required recipe.nodes table"
	end
	recipe.root = nil
	local canrot
	for _, v in pairs(recipe.nodes) do
		v.x = v.x or 0
		v.y = v.y or 0
		v.z = v.z or 0
		canrot = canrot or v.x ~= 0 or v.z ~= 0
		if v.x == 0 and v.y == 0 and v.z == 0 then
			recipe.root = v
		end
	end
	if not recipe.root or not recipe.root.match then
		error "recipe.nodes must have a match for 0,0,0"
	end
	if not canrot then recipe.norotate = true end
	if recipe.normal then
		recipe.normal.x = recipe.normal.x or 0
		recipe.normal.y = recipe.normal.y or 0
		recipe.normal.z = recipe.normal.z or 0
	end
	local newp = recipe.priority or 0
	local min = 1
	local max = #recipes + 1
	while max > min do
		local try = math_floor((min + max) / 2)
		local oldp = recipes[try].priority or 0
		if newp < oldp then
			min = try + 1
		else
			max = try
		end
	end
	table_insert(recipes, min, recipe)
end

local function craftcheck(recipe, pos, node, placer, pointed_thing, xx, xz, zx, zz)
	local function rel(x, y, z)
		return {
			x = pos.x + xx * x + zx * z,
			y = pos.y + y,
			z = pos.z + xz * x + zz * z
		}
	end
	if recipe.check and not recipe.check(pos, rel, placer, pointed_thing) then return end
	if recipe.normal then
		if pointed_thing.type ~= "node" or
		recipe.normal.y ~= pointed_thing.above.y - pointed_thing.under.y then return end
		local rx = recipe.normal.x * xx + recipe.normal.z * zx
		if rx ~= pointed_thing.above.x - pointed_thing.under.x then return end
		local rz = recipe.normal.x * xz + recipe.normal.z * zz
		if rz ~= pointed_thing.above.z - pointed_thing.under.z then return end
	end
	for _, v in pairs(recipe.nodes) do
		if v ~= recipe.root and v.match then
			local p = rel(v.x, v.y, v.z)
			if not nodecore.node_is(p, v.match) then return end
		end
	end
	for _, v in pairs(recipe.nodes) do
		if v.replace then
			local p = rel(v.x, v.y, v.z)
			local r = v.replace
			while type(r) == "function" do
				r = r(p, v)
			end
			if r and type(r) == "string" then
				r = {name = r}
			end
			if r then minetest.set_node(p, r) end
		end
	end
	if recipe.items then
		for _, v in pairs(recipe.items) do
			nodecore.item_eject(rel(v.x or 0, v.y or 0, v.z or 0), v)
		end
	end
	if recipe.after then recipe.after(pos, rel, placer, pointed_thing) end
	return true
end

function nodecore.craft_check(pos, node, placer, pointed_thing)
	for _, rc in ipairs(recipes) do
		if nodecore.node_is(node, rc.root.match) then
			if craftcheck(rc, pos, node, placer, pointed_thing,
				1, 0, 0, 1) then return true end
			if not rc.norotate then
				if craftcheck(rc, pos, node, placer, pointed_thing,
					0, -1, 1, 0) then return true end
				if craftcheck(rc, pos, node, placer, pointed_thing,
					-1, 0, 0, -1) then return true end
				if craftcheck(rc, pos, node, placer, pointed_thing,
					0, 1, -1, 0) then return true end
				if not rc.nomirror then
					if craftcheck(rc, pos, node, placer, pointed_thing,
						-1, 0, 0, 1) then return true end
					if craftcheck(rc, pos, node, placer, pointed_thing,
						0, 1, 1, 0) then return true end
					if craftcheck(rc, pos, node, placer, pointed_thing,
						1, 0, 0, -1) then return true end
					if craftcheck(rc, pos, node, placer, pointed_thing,
						0, -1, -1, 0) then return true end
				end
			end
		end
	end
end

function minetest.item_place_node(itemstack, placer, pointed_thing, ...)
	local old_add = minetest.add_node
	minetest.add_node = function(pos, node, ...)
		local function helper2(...)
			nodecore.craft_check(pos, node, placer, pointed_thing)
			return ...
		end
		return helper2(old_add(pos, node, ...))
	end
	local function helper(...)
		minetest.add_node = old_add
		return ...
	end
	return helper(old_place(itemstack, placer, pointed_thing, ...))
end
