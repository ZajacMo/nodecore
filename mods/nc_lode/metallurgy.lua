local modname = minetest.get_current_modname()

local function reg(shape, rawdef)
	for _, temper in pairs({"Hot", "Annealed", "Tempered"}) do
		local def = nodecore.underride({}, rawdef)
		def = nodecore.underride(def, {
				description = temper .. " Lode " .. shape,
				name = (shape .. "_" .. temper):lower(),
				groups = { cracky = 3 }
			})
		if temper ~= "Hot" then
			def.light_source = nil
		else
			def.groups = def.groups or {}
			def.groups.falling_node = 1
		end

		if def.tiles then
			local t = {}
			for k, v in pairs(def.tiles) do
				t[k] = v:gsub("#", temper:lower())
			end
			def.tiles = t
		end
		def.inventory_image = def.inventory_image and 
		def.inventory_image:gsub("#", temper:lower())

		minetest.log("REG: " .. modname .. ":" .. def.name)
		minetest.register_item(modname .. ":" .. def.name, def)
	end
end

reg("Prill", {
		type = "craft",
		inventory_image = modname .. "_#.png^[mask:" .. modname .. "_mask_prill.png"
	})
reg("Slab", {
		type = "node",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(-0.5, -0.5, -0.5, 0.5, 0, 0.5),
		tiles = { modname .. "_#.png" },
		paramtype = "light",
		light_source = 6
	})
reg("Block", {
		type = "node",
		tiles = { modname .. "_#.png" },
		light_source = 8
	})