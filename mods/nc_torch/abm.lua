-- LUALOCALS < ---------------------------------------------------------
local core, math, nc, pairs, vector
    = core, math, nc, pairs, vector
local math_ceil, math_log, math_random
    = math.ceil, math.log, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local checkdirs = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1},
	{x = 0, y = 1, z = 0}
}
core.register_abm({
		label = "torch ignite",
		interval = 6,
		chance = 1,
		nodenames = {"group:torch_lit"},
		neighbors = {"group:flammable"},
		action_delay = true,
		action = function(pos)
			for _, ofst in pairs(checkdirs) do
				local npos = vector.add(pos, ofst)
				local nbr = core.get_node(npos)
				if core.get_item_group(nbr.name, "flammable") > 0
				and not nc.quenched(npos) then
					nc.fire_check_ignite(npos, nbr)
				end
			end
		end
	})

local log2 = math_log(2)
local function torchlife(expire, pos)
	local max = nc.torch_life_stages
	if expire <= nc.gametime then return max end
	local life = (expire - nc.gametime) / nc.torch_life_base
	if life > 1 then return 1 end
	local stage = 1 - math_ceil(math_log(life) / log2)
	if stage < 1 then return 1 end
	if stage > max then return max end
	if pos and (stage >= 2) then
		nc.smokefx(pos, {
				time = 1,
				rate = (stage - 1) / 2,
				scale = 0.25
			})
	end
	return stage
end

local function snufffx(pos)
	nc.smokeburst(pos, 3)
	return nc.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
end

core.register_abm({
		label = "torch snuff",
		interval = 1,
		chance = 1,
		nodenames = {"group:torch_lit"},
		action = function(pos, node)
			local expire = nc.get_torch_expire(core.get_meta(pos), node.name)
			if nc.quenched(pos) or nc.gametime > expire then
				core.remove_node(pos)
				core.add_item(pos, {name = "nc_fire:lump_ash"})
				snufffx(pos)
				return
			end
			local nn = modname .. ":torch_lit_" .. torchlife(expire, pos)
			if node.name ~= nn then
				node.name = nn
				return core.swap_node(pos, node)
			end
		end
	})

nc.register_aism({
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

			local expire, dirty = nc.get_torch_expire(stack:get_meta(), stack:get_name())
			if (expire < nc.gametime)
			or nc.quenched(pos, data.node and 1 or 0.3) then
				snufffx(pos)
				return "nc_fire:lump_ash"
			end

			if wield and math_random() < 0.1 then nc.fire_check_ignite(pos) end

			local nn = modname .. ":torch_lit_" .. torchlife(expire, pos)
			if stack:get_name() ~= nn then
				stack:set_name(nn)
				return stack
			elseif dirty then
				return stack
			end
		end
	})
