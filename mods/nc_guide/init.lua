-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, type
    = ipairs, minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local function conv(spec)
	if not spec then
		return function() return true end
	end
	if type(spec) == "function" then return spec end
	if type(spec) == "table" then
		local f = spec[1]
		if f == true then
			return function(db)
				for i = 2, #spec do
					if db[spec[i]] then return true end
				end
			end
		end
		return function(db)
			for i = 2, #spec do
				if not db[spec[i]] then return end
			end
			return true
		end
	end
	return function(db) return db[spec] end
end

local function addhint(text, goal, reqs)
	local hints = nodecore.hints
	local h = {
		text = text,
		goal = conv(goal),
		reqs = conv(reqs)
	}
	hints[#hints + 1] = h
	return h
end
nodecore.hints = {}
nodecore.addhint = addhint

addhint("dug up dirt",
	"nc_terrain:dirt_loose")

addhint("dug up sand",
	"nc_terrain:sand_loose")

addhint("found dry leaves",
	"nc_tree:leaves_loose")

addhint("found eggcorns",
	"nc_tree:eggcorn")

addhint("planted an eggcorn",
	"nc_tree:eggcorn_planted")

addhint("found sticks",
	"nc_tree:stick")

addhint("crafted a staff from sticks",
	"nc_woodwork:staff",
	"nc_tree:stick")

addhint("crafted an adze out of sticks",
	"nc_woodwork:adze",
	{true, "nc_tree:stick", "nc_woodwork:staff"})

addhint("constructed a wooden ladder",
	"nc_woodwork:ladder",
	{true, "nc_tree:stick", "nc_woodwork:staff"})

addhint("constructed a wooden frame",
	"nc_woodwork:frame",
	{true, "nc_tree:stick", "nc_woodwork:staff"})

addhint("split a tree trunk into planks",
	"nc_woodwork:plank",
	{true, "nc_woodwork:adze", "nc_woodwork:tool_hatchet"})

local woodhead = addhint("made wooden tool heads out of planks",
	{true,
		"nc_woodwork:toolhead_mallet",
		"nc_woodwork:toolhead_spade",
		"nc_woodwork:toolhead_hatchet",
		"nc_woodwork:toolhead_pick",
	},
	"nc_woodwork:plank")

addhint("assembled a wooden tool",
	{true,
		"nc_woodwork:tool_mallet",
		"nc_woodwork:tool_spade",
		"nc_woodwork:tool_hatchet",
		"nc_woodwork:tool_pick",
	},
	woodhead.goal)

addhint("made all the different kinds of wooden tool heads",
	{
		"nc_woodwork:toolhead_mallet",
		"nc_woodwork:toolhead_spade",
		"nc_woodwork:toolhead_hatchet",
		"nc_woodwork:toolhead_pick",
	},
	woodhead.goal)

addhint("cut down a tree",
	"nc_tree:tree",
	"nc_woodwork:tool_hatchet")

addhint("dug up stone",
	"nc_terrain:cobble_loose",
	"nc_woodwork:tool_pick")

addhint("broken cobble into chips",
	"nc_stonework:chip",
	"nc_terrain:cobble_loose")

addhint("added a stone tip onto a tool",
	{true,
		"nc_stonework:tool_mallet",
		"nc_stonework:tool_spade",
		"nc_stonework:tool_hatchet",
		"nc_stonework:tool_pick"
	},
	"nc_stonework:chip")

local embers = addhint("started a fire by rubbing sticks together",
	{true,
		"nc_fire:ember1",
		"nc_fire:ember2",
		"nc_fire:ember3",
		"nc_fire:ember4",
		"nc_fire:ember5",
		"nc_fire:ember6",
		"nc_fire:ash",
	},
	"nc_tree:stick")

addhint("gotten a fire going with long-lasting fuel?",
	{true,
		"nc_fire:ember5",
		"nc_fire:ember6",
		"nc_fire:ash",
	},
	embers.goal)

addhint("found ash",
	"nc_fire:ash",
	embers.goal)

local lodefind = addhint("found a lode deposit",
	{true,
		"nc_lode:stone",
		"nc_lode:ore"
	})

local lodeore = addhint("found lode ore",
	"nc_lode:ore",
	lodefind.goal)

addhint("dug out lode ore",
	"nc_lode:cobble_loose",
	lodeore.goal)

local lodesmelt = addhint("extracted metal from lode cobble",
	{true,
		"nc_lode:prill_hot",
		"nc_lode:prill_annealed",
		"nc_lode:prill_tempered"
	},
	"nc_lode:cobble_loose")

addhint("annealed lode",
	{true,
		"nc_lode:prill_annealed",
		"nc_lode:slab_annealed",
		"nc_lode:block_annealed"
	},
	lodesmelt.goal)

addhint("quenched lode",
	{true,
		"nc_lode:prill_tempered",
		"nc_lode:slab_tempered",
		"nc_lode:block_tempered"
	},
	lodesmelt.goal)

local function sethint(player)
	local pname = player:get_player_name()

	local rawdb = nodecore.statsdb[pname]
	local db = {}
	for _, r in ipairs({"inv", "punch", "dig", "place"}) do
		for k, v in pairs(rawdb[r]) do
			db[k] = v
		end
	end

	local found = {}
	for _, hint in ipairs(nodecore.hints) do
		if hint.reqs(db) and not hint.goal(db) then
			found[#found + 1] = hint.text
		end
	end
	found = nodecore.pickrand(found)
	if not found then
		player:set_inventory_formspec(nodecore.inventory_formspec)
	end

	return player:set_inventory_formspec(nodecore.inventory_formspec
		.. "label[0,3.1;...have you "
		.. minetest.formspec_escape(found)
		.. " yet...?")
end

minetest.register_on_joinplayer(function(player)
		minetest.after(0, function() sethint(player) end)
	end)

local seen

minetest.register_globalstep(function()
		if not seen then return end
		for _, player in pairs(minetest.get_connected_players()) do
			local n = player:get_player_name()
			if not seen[n] then
				seen[n] = true
				return sethint(player)
			end
		end
		seen = nil
	end)

local function pump()
	minetest.after(20, pump)
	seen = seen or {}
end
pump()
