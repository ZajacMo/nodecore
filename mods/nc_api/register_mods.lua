-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, string, table
    = minetest, nodecore, pairs, string, table
local string_format, table_concat, table_sort
    = string.format, table.concat, table.sort
-- LUALOCALS > ---------------------------------------------------------

nodecore.coremods = {}

function nodecore.amcoremod(v)
	nodecore.coremods[minetest.get_current_modname()] = (v == nil) or v
end
nodecore.amcoremod()

for k, v in pairs(minetest.registered_chatcommands) do
	if k == "mods" then
		minetest.override_chatcommand(k, nodecore.underride({
					func = function()
						local mods = {}
						for _, n in pairs(minetest.get_modnames()) do
							if not nodecore.coremods[n] then
								mods[#mods + 1] = n
							end
						end
						table_sort(mods)
						return true, string_format("%s(%s)%s%s",
							nodecore.product,
							nodecore.version or "DEV",
							#mods > 0 and " + " or "",
							table_concat(mods, ", "))
					end
				}, v))
	end
end
