-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs
    = core, nc, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local function mktool(tshape, buffs)
	buffs = buffs or {}
	for _, temper in pairs({"tempered", "annealed"}) do
		local orig = core.registered_items["nc_lode:" .. tshape .. "_" .. temper]

		local def = nc.underride({
				description = "Infused " .. orig.description,
				inventory_image = orig.inventory_image .. "^(" .. modname
				.. "_base.png^[mask:" .. modname
				.. "_infuse_mask.png^[mask:nc_lode_" .. tshape
				.. ".png^[opacity:80)",
				tool_wears_to = orig.name,
				glow = 1
			}, orig)
		def.after_use = nil

		def.groups = nc.underride({lux_tool = 1, lux_emit = 1}, orig.groups or {})
		if def.groups.rakey then def.groups.rakey = def.groups.rakey + 1 end
		local tc = {}
		for k, v in pairs(orig.tool_capabilities.opts) do
			tc[k] = v + 1 + (buffs[k] or 0)
		end
		tc.uses = 0.125 * (buffs.uses or 1)
		def.tool_capabilities = nc.toolcaps(tc)
		if def.on_rake then
			def.on_rake = nc.lode_rake_function(def.tool_capabilities)
		end

		for k, v in pairs(orig.tool_capabilities.opts) do
			tc[k] = v + 2 + (buffs[k] or 0)
		end
		local boosttc = nc.toolcaps(tc)
		local boost = nc.underride({
				inventory_image = orig.inventory_image .. "^(" .. modname
				.. "_base.png^[mask:" .. modname
				.. "_infuse_mask.png^[mask:nc_lode_" .. tshape
				.. ".png^[opacity:120)",
				tool_capabilities = boosttc,
				glow = 2,
				light_source = 1,
				on_rake = def.on_rake and nc.lode_rake_function(boosttc)
			}, def)

		boost.groups = nc.underride({lux_tool = 1, lux_emit = 2}, def.groups)

		def.name = modname .. ":" .. tshape .. "_" .. temper
		boost.name = modname .. ":" .. tshape .. "_" .. temper .. "_boost"

		def.alternative_lux_boosted = boost.name
		boost.alternative_lux_unboosted = def.name

		core.override_item(orig.name, {alternative_lux_infused = def.name})
		core.register_tool(def.name, def)
		core.register_tool(boost.name, boost)
	end
end
for _, shape in pairs({"mallet", "spade", "hatchet", "pick", "mattock"}) do
	mktool("tool_" .. shape)
end
mktool("adze")
mktool("rake", {snappy = 3, crumbly = 3, uses = 5})
