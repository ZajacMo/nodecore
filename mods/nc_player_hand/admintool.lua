-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, nc, string
    = ItemStack, core, nc, string
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local supername = modname .. ":super"
local superdef = nc.underride({
		description = "Admin Tool",
		light_source = 14,
		tiles = {"[combine:1x1^[noalpha^[colorize:#ffffff:255"},
		inventory_image = modname .. "_admintool.png",
		tool_capabilities = nc.toolcaps({
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
		on_place = function() end,
		mapcolor = {a = 0},
	}, core.registered_nodes[modname .. ":hand"])
superdef.on_use = nil
core.register_node(supername, superdef)

core.register_chatcommand("nckfa", {
		description = "Summon admin tool",
		privs = {give = true},
		func = function(name)
			core.registered_chatcommands.giveme.func(name, supername)
		end
	})

local cooldown = {}
core.register_on_punchnode(function(pos, node, puncher)
		if not (puncher and puncher:is_player()) then return end

		local ctl = puncher:get_player_control()
		if not (ctl.sneak and ctl.aux1) then return end

		local wield = puncher:get_wielded_item()
		if wield:get_name() ~= supername then return end

		if node.name == "air" or node.name == "ignore" then return end

		local now = core.get_us_time()
		local pname = puncher:get_player_name()
		local cd = cooldown[pname]
		if cd and cd > now then return end
		cooldown[pname] = now + 250 * 1000

		if not nc.stack_giveto(pos, puncher) then
			nc.item_eject(pos, nc.stack_get(pos))
		end

		nc.log("action", string_format("%s super-digs %s at %s",
				pname, node.name, core.pos_to_string(pos)))

		local def = core.registered_nodes[node.name]
		if (not def) or (not def.air_equivalent) and (not def.groups.is_stack_only) then
			local stack = ItemStack(node.name)
			stack:get_meta():from_table({fields = core.get_meta(pos)
					:to_table().field})
			stack = puncher:get_inventory():add_item("main", stack)
			if not stack:is_empty() then nc.item_eject(pos, stack) end
		end

		core.remove_node(pos)
		return nc.fallcheck(pos)
	end)
