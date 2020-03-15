-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs, setmetatable, vector
    = ItemStack, minetest, nodecore, pairs, setmetatable, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function islit(stack)
	return stack and stack:get_name() == modname .. ":torch_lit"
end

local function snuffinv(player, inv, i)
	minetest.sound_play("nc_fire_snuff", {object = player, gain = 0.5})
	inv:set_stack("main", i, "nc_fire:lump_ash")
end

local bright = nodecore.dynamic_light_node(8)
local dim = nodecore.dynamic_light_node(4)

local ambtimers = {}
minetest.register_globalstep(function()
		local now = nodecore.gametime
		for _, player in pairs(minetest.get_connected_players()) do
			local inv = player:get_inventory()
			local ppos = player:get_pos()

			-- Snuff all torches if doused in water.
			local hpos = vector.add(ppos, {x = 0, y = 1, z = 0})
			local head = minetest.get_node(hpos).name
			if minetest.get_item_group(head, "water") > 0 then
				for i = 1, inv:get_size("main") do
					local stack = inv:get_stack("main", i)
					if islit(stack) then snuffinv(player, inv, i) end
				end
			elseif islit(player:get_wielded_item()) then
				-- Wield light
				local name = player:get_player_name()
				nodecore.dynamic_light_add(hpos, bright, 0.5)

				-- Wield ambiance
				local t = ambtimers[name] or 0
				if t <= now then
					ambtimers[name] = now + 1
					minetest.sound_play("nc_fire_flamy",
						{object = player, gain = 0.1})
				end
			else
				-- Dimmer non-wielded carry light
				for i = 1, inv:get_size("main") do
					if islit(inv:get_stack("main", i)) then
						nodecore.dynamic_light_add(hpos, dim, 0.5)
					end
				end
			end
		end
	end)

-- Apply wield light to entities as well.
local function entlight(self, dtime, ...)
	local stack = ItemStack(self.node and self.node.name or self.itemstring or "")
	if not islit(stack) then return ... end
	local wltime = (self.wltime or 0) - dtime
	if wltime <= 0 then
		wltime = 0.2
		nodecore.dynamic_light_add(self.object:get_pos(), bright, 0.3)
	end
	self.wltime = wltime
	return ...
end
for _, name in pairs({"item", "falling_node"}) do
	local def = minetest.registered_entities["__builtin:" .. name]
	local ndef = {
		on_step = function(self, dtime, ...)
			return entlight(self, dtime, def.on_step(self, dtime, ...))
		end
	}
	setmetatable(ndef, def)
	minetest.register_entity(":__builtin:" .. name, ndef)
end
