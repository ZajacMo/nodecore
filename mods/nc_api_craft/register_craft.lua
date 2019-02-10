-- LUALOCALS < ---------------------------------------------------------
local error, math, nodecore, pairs, table, type
    = error, math, nodecore, pairs, table, type
local math_floor, table_insert
    = math.floor, table.insert
-- LUALOCALS > ---------------------------------------------------------

local craft_recipes = {}
nodecore.craft_recipes = craft_recipes

local id = 0

function nodecore.register_craft(recipe)
	recipe.action = recipe.action or "place"
	local canrot
	recipe.nodes = recipe.nodes or {}
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
	if not recipe.label then
		id = id + 1
		recipe.label = "unnamed " .. recipe.action .. " " .. id
	end
	if recipe.toolgroups and recipe.toolwear ~= false then
		recipe.toolwear = 1
	end
	if not canrot then recipe.norotate = true end
	if recipe.normal then
		recipe.normal.x = recipe.normal.x or 0
		recipe.normal.y = recipe.normal.y or 0
		recipe.normal.z = recipe.normal.z or 0
	end
	if recipe.items then
		for k, v in pairs(recipe.items) do
			if type(v) == "string" then
				recipe.items[k] = {name = v}
			end
		end
	end
	local newp = recipe.priority or 0

	local min = 1
	local max = #craft_recipes + 1
	while max > min do
		local try = math_floor((min + max) / 2)
		local oldp = craft_recipes[try].priority or 0
		if newp < oldp then
			min = try + 1
		else
			max = try
		end
	end
	table_insert(craft_recipes, min, recipe)
end
