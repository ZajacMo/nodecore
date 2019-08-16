-- LUALOCALS < ---------------------------------------------------------
local minetest, pairs, string
    = minetest, pairs, string
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

local genlabels = 0

local oldreg = minetest.register_abm
function minetest.register_abm(def, ...)
	local label = def.label
	if not label then
		label = minetest.get_current_modname() .. ":" .. genlabels
		genlabels = genlabels + 1
	end

	local function report(pos, issue)
		return minetest.log("issue8378 abm "
			.. string_format("%q", label) .. " for "
			.. minetest.pos_to_string(pos) .. ": " .. issue)
	end

	local names = {}
	local groups = {}
	for _, n in pairs(def.nodenames or {}) do
		if n:sub(1, 6) == "group:" then
			groups[n:sub(7)] = true
		else
			names[n] = true
		end
	end

	local oldact = def.action
	if oldact then
		def.action = function(pos, _, ...)
			local node = minetest.get_node_or_nil(pos)
			if not node then return report("ignore") end
			if not names[node.name] then
				local def = minetest.registered_items[node.name]
				if not def then return report("undefined node " .. node.name) end
				local ok
				for k in pairs(groups) do
					ok = ok or (def.groups[k] or 0) > 0
				end
				if not ok then report("wrong node " .. node.name) end
			end
			return oldact(pos, node, ...)
		end
	end

	return oldreg(def, ...)
end
