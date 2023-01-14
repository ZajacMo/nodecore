-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, string
    = ItemStack, minetest, nodecore, string
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local supername = modname .. ":super"
local superdef = nodecore.underride({
		description = "Admin Tool",
		light_source = 14,
		tiles = {"[combine:1x1^[noalpha^[colorize:#ffffff:255"},
		inventory_image = modname .. "_admintool.png",
		tool_capabilities = nodecore.toolcaps({
				uses = 0,
				cracky = 100,
				crumbly = 100,
				choppy = 100,
				snappy = 100,
				thumpy = 100
			}),
		groups = {cheat = 1},
		virtual_item = true,
		on_drop = function() return ItemStack("") end,
		on_place = function() end
	}, minetest.registered_nodes[modname .. ":hand"])
superdef.on_use = nil
minetest.register_node(supername, superdef)

minetest.register_chatcommand("nckfa", {
		description = "Summon admin tool",
		privs = {give = true},
		func = function(name)
			minetest.registered_chatcommands.giveme.func(name, supername)
		end
	})

local cooldown = {}
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

		if not nodecore.stack_giveto(pos, puncher) then
			nodecore.item_eject(pos, nodecore.stack_get(pos))
		end

		nodecore.log("action", string_format("%s super-digs %s at %s",
				pname, node.name, minetest.pos_to_string(pos)))

		local def = minetest.registered_nodes[node.name]
		if (not def) or (not def.air_equivalent) and (not def.groups.is_stack_only) then
			local stack = ItemStack(node.name)
			stack:get_meta():from_table({fields = minetest.get_meta(pos)
					:to_table().field})
			stack = puncher:get_inventory():add_item("main", stack)
			if not stack:is_empty() then nodecore.item_eject(pos, stack) end
		end

		minetest.remove_node(pos)
		return nodecore.fallcheck(pos)
	end)
