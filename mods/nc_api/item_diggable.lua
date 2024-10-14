-- LUALOCALS < ---------------------------------------------------------
local nc, pairs, type
    = nc, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local diggroups = {
	cracky = true,
	choppy = true,
	crumbly = true,
	snappy = true
}

nc.register_on_register_item(function(_, def)
		if def.diggable ~= nil then return end

		if def.pointable == false then
			def.diggable = false
			return
		end

		if def.liquidtype ~= nil and def.liquidtype ~= "none" then
			def.diggable = false
			return
		end

		if def.groups then
			for k in pairs(diggroups) do
				if type(def.groups[k]) == "number" and def.groups[k] > 0 then
					return
				end
			end
		end
		def.diggable = false
	end)
