-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, rawset, setmetatable, type
    = ipairs, minetest, nodecore, pairs, rawset, setmetatable, type
-- LUALOCALS > ---------------------------------------------------------

local regs = {}
nodecore.registered_on_register_item = regs

function nodecore.register_on_register_item(def)
	if type(def) == "function" then def = {func = def} end
	regs[#regs + 1] = def
	if def.retroactive then
		local snapshot = {}
		for name, itemdef in pairs(minetest.registered_items) do
			snapshot[name] = itemdef
		end
		for name, itemdef in pairs(snapshot) do
			local t = {}
			setmetatable(t, {
					__index = itemdef,
					__newindex = function(_, k, v)
						return rawset(itemdef, k, v)
					end
				})
			def.func(name, itemdef)
		end
	end
end

local oldreg = minetest.register_item
function minetest.register_item(name, def, ...)
	for _, v in ipairs(nodecore.registered_on_register_item) do
		local x = v.func(name, def, ...)
		if x then return x end
	end
	return oldreg(name, def, ...)
end
