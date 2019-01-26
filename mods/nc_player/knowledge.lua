-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs
    = ipairs, minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local store = minetest.get_mod_storage()

local knowcache = {}

local function addknow(player, tag)
	if not player or not player:is_player() then return end
	local pname = player:get_player_name()
	local know = knowcache[pname]
	if not know then
		know = store:get_string(pname)
		know = know and minetest.deserialize(know)
		know = know or { }
	end
	if know[tag] then return end
	know[tag] = true
	know = minetest.serialize(know)
	store:set_string(pname, know)
end
nodecore.player_knowledge_add = addknow

function nodecore.player_knowledge()
	return store:to_table().fields
end

minetest.register_on_punchnode(function(pos, node, puncher)
		addknow(puncher, "punch:" .. node.name)
	end)
minetest.register_on_dignode(function(pos, node, digger)
		addknow(digger, "dig:" .. node.name)
	end)

local function hook(orig, ext)
	return function(...)
		ext(...)
		return orig(...)
	end
end
minetest.item_place = hook(minetest.item_place, function(stack, player)
		if stack:is_empty() then return end
		addknow(player, "place:" .. stack:get_name())
	end)

local function invscan()
	for _, player in ipairs(minetest.get_connected_players()) do
		local inv = player:get_inventory()
		local t = {}
		for i = 1, inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			if not stack:is_empty() then
				t[stack:get_name()] = true
			end
		end
		for k, v in pairs(t) do
			addknow(player, "inv:" .. k)
		end
	end
	minetest.after(1, invscan)
end
invscan()
