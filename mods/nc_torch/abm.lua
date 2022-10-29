-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_ceil, math_log, math_random
    = math.ceil, math.log, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local checkdirs = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1},
	{x = 0, y = 1, z = 0}
}
minetest.register_abm({
		label = "torch ignite",
		interval = 6,
		chance = 1,
		nodenames = {"group:torch_lit"},
		neighbors = {"group:flammable"},
		action_delay = true,
		action = function(pos)
			for _, ofst in pairs(checkdirs) do
				local npos = vector.add(pos, ofst)
				local nbr = minetest.get_node(npos)
				if minetest.get_item_group(nbr.name, "flammable") > 0
				and not nodecore.quenched(npos) then
					nodecore.fire_check_ignite(npos, nbr)
				end
			end
		end
	})

local log2 = math_log(2)
local function torchlife(expire, pos)
	local max = nodecore.torch_life_stages
	if expire <= nodecore.gametime then return max end
	local life = (expire - nodecore.gametime) / nodecore.torch_life_base
	if life > 1 then return 1 end
	local stage = 1 - math_ceil(math_log(life) / log2)
	if stage < 1 then return 1 end
	if stage > max then return max end
	if pos and (stage >= 2) then
		nodecore.smokefx(pos, {
				time = 1,
				rate = (stage - 1) / 2,
				scale = 0.25
			})
	end
	return stage
end

local function snufffx(pos)
	nodecore.smokeburst(pos, 3)
	return nodecore.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
end

minetest.register_abm({
		label = "torch snuff",
		interval = 1,
		chance = 1,
		nodenames = {"group:torch_lit"},
		action = function(pos, node)
			local expire = nodecore.get_torch_expire(minetest.get_meta(pos), node.name)
			if nodecore.quenched(pos) or nodecore.gametime > expire then
				minetest.remove_node(pos)
				minetest.add_item(pos, {name = "nc_fire:lump_ash"})
				snufffx(pos)
				return
			end
			local nn = modname .. ":torch_lit_" .. torchlife(expire, pos)
			if node.name ~= nn then
				node.name = nn
				return minetest.swap_node(pos, node)
			end
		end
	})

nodecore.register_aism({
		label = "torch stack interact",
		itemnames = {"group:torch_lit"},
		action = function(stack, data)
			local pos = data.pos
			local player = data.player
			local wield
			if player and data.list == "main"
			and player:get_wield_index() == data.slot then
				wield = true
				pos = vector.add(pos, vector.multiply(player:get_look_dir(), 0.5))
			end

			local expire, dirty = nodecore.get_torch_expire(stack:get_meta(), stack:get_name())
			if (expire < nodecore.gametime)
			or nodecore.quenched(pos, data.node and 1 or 0.3) then
				snufffx(pos)
				return "nc_fire:lump_ash"
			end

			if wield and math_random() < 0.1 then nodecore.fire_check_ignite(pos) end

			local nn = modname .. ":torch_lit_" .. torchlife(expire, pos)
			if stack:get_name() ~= nn then
				stack:set_name(nn)
				return stack
			elseif dirty then
				return stack
			end
		end
	})
