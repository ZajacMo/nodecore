-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, nc, pairs, rawset, setmetatable, type
    = core, ipairs, nc, pairs, rawset, setmetatable, type
-- LUALOCALS > ---------------------------------------------------------

local regs = {}
nc.registered_on_register_item = regs

function nc.register_on_register_item(def)
	if type(def) == "function" then def = {func = def} end
	regs[#regs + 1] = def
	if def.retroactive then
		local snapshot = {}
		for name, itemdef in pairs(core.registered_items) do
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

local oldreg = core.register_item
function core.register_item(name, def, ...)
	local canonical_name = name:gsub("^:", "")
	for _, v in ipairs(nc.registered_on_register_item) do
		local x = v.func(canonical_name, def, ...)
		if x then return x end
	end
	return oldreg(name, def, ...)
end
