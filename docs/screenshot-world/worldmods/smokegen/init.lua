-- LUALOCALS < ---------------------------------------------------------
local PcgRandom, math, minetest, nodecore, pairs
    = PcgRandom, math, minetest, nodecore, pairs
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local entname = modname .. ":ent"
local genname = modname .. ":gen"

minetest.register_entity(entname, {
		description = "Smoke",
		initial_properties = {
			visual = "sprite",
			visual_size = {x = 1/4, y = 1/4, z = 1/4},
			textures = {"nc_api_craft_smoke.png"},
			physical = false,
			pointable = false,
			static_save = false,
		}
	})

minetest.register_node(genname, {
		description = "Smoke Generator",
		inventory_image = "nc_api_craft_smoke.png",
		wield_image = "nc_api_craft_smoke.png",
		drawtype = "airlike",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		groups = {snappy = 1}
	})

local smokepuffs = {}

local function myround(n)
	return math_floor(n * 256) / 256
end

nodecore.register_dnt({
		name = genname,
		nodenames = {genname},
		time = 1,
		loop = true,
		ignore_stasis = true,
		autostart = true,
		autostart_time = 0,
		action = function(pos)
			local pcg = PcgRandom(minetest.hash_node_position(pos))
			local rng = function() return pcg:next() / 2 ^ 32 + 0.5 end
			for _ = 1, 10 do
				local p = {
					x = myround(pos.x + rng() - 0.5),
					y = myround(pos.y + rng() * 2 - 0.5),
					z = myround(pos.z + rng() - 0.5),
					src = pos
				}
				smokepuffs[minetest.pos_to_string(p)] = p
			end
		end
	})

nodecore.interval(1, function()
		local found = {}
		for _, ent in pairs(minetest.luaentities) do
			if ent.name == entname then
				local key = ent.key
				local puff = key and smokepuffs[key]
				if not (puff and puff.src
					and minetest.get_node(puff.src).name == genname) then
					ent.object:remove()
					smokepuffs[key] = nil
				end
				found[key] = ent
			end
		end
		for key, pos in pairs(smokepuffs) do
			if not found[key] then
				local obj = minetest.add_entity(pos, entname)
				local ent = obj and obj:get_luaentity()
				if ent then ent.key = key end
			end
		end
	end)
