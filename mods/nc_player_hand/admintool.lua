-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local supername = modname .. ":super"
minetest.register_node(supername, nodecore.underride({
			description = "HAND OF POWER",
			light_source = 14,
			tiles = {"[combine:1x1^[noalpha^[colorize:#ffffff:255"},
			tool_capabilities = nodecore.toolcaps({
					uses = 0,
					cracky = 100,
					crumbly = 100,
					choppy = 100,
					snappy = 100,
					thumpy = 100
				}),
			virtual_item = true,
			on_drop = function() return ItemStack("") end,
			on_place = function() end
		}, minetest.registered_nodes[modname .. ":hand"]))

minetest.register_chatcommand("nckfa", {
		description = "Summon admin tool",
		privs = {give = true},
		func = function(name)
			minetest.registered_chatcommands.giveme.func(name, supername)
		end
	})

local cooldown = {}
local function givestack(pos, player, stack)
	if stack:is_empty() then return end
	stack = player:get_inventory():add_item("main", stack)
	if stack:is_empty() then return end
	return nodecore.item_eject(pos, stack)
end
minetest.register_on_punchnode(function(pos, node, puncher)
		if not (puncher and puncher:is_player()) then return end

		local ctl = puncher:get_player_control()
		if not (ctl.sneak and ctl.aux1) then return end

		local wield = puncher:get_wielded_item()
		if wield:get_name() ~= supername then return end

		if node.name == "air" or node.name == "ignore" then return end

		local now = minetest.get_us_time()
		local pname = puncher:get_player_name()
		local cd = cooldown[pname]
		if cd and cd > now then return end
		cooldown[pname] = now + 250 * 1000

		givestack(pos, puncher, nodecore.stack_get(pos))

		local def = minetest.registered_nodes[node.name]
		if (not def) or (not def.air_equivalent) and (not def.groups.is_stack_only) then
			local stack = ItemStack(node.name)
			stack:get_meta():from_table({fields = minetest.get_meta(pos)
					:to_table().field})
			givestack(pos, puncher, stack)
		end

		minetest.remove_node(pos)
	end)
