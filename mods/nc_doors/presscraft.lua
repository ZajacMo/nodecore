-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs
    = ipairs, minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local done = {}

local function pressify(rc)
	if rc.action ~= "pummel" then return end

	local thumpy = rc.toolgroups and rc.toolgroups.thumpy
	if not thumpy then return end

	if done[rc.label] then return end
	done[rc.label] = true

	local nr = {}
	for k, v in pairs(rc) do nr[k] = v end

	nr.label = "press " .. nr.label
	nr.action = "press"
	nr.toolgroups = nil

	local oldcheck = nr.check
	nr.check = function(pos, data)
		local g = nodecore.node_group("door", data.pointed.above) or 0
		if g < thumpy then return end
		if oldcheck then return oldcheck(pos, data) end
		return true
	end

	nodecore.register_craft(nr)
end

minetest.after(0, function()
		local t = {}
		for _, v in ipairs(nodecore.craft_recipes) do t[#t + 1] = v end
		minetest.after(0, function()
				for _, v in ipairs(t) do pressify(v) end
			end)
	end)

local oldreg = nodecore.register_craft
nodecore.register_craft = function(def, ...)
	local function helper(...)
		pressify(def)
		return ...
	end
	return helper(oldreg(def, ...))
end
