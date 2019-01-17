-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

function nodecore.ignite(pos, node)
	local fuel = nodecore.node_group("fire_fuel", pos, node) or 0
	if fuel < 0 then fuel = 0 end
	if fuel > 6 then fuel = 6 end
	fuel = math_floor(fuel)
	minetest.set_node(pos, {name = modname .. ((fuel > 0)
				and (":ember" .. fuel) or ":fire")})
	minetest.after(0, function() minetest.check_for_falling(pos) end)
end

function nodecore.snuff(pos, node, groups)
	local ember = nodecore.node_group("ember", pos, node)
	if not ember then return end
	ember = ember - 1
	minetest.set_node(pos, {name = modname .. ((ember > 0)
				and (":ember" .. ember) or ":ash")})
	minetest.after(0, function() minetest.check_for_falling(pos) end)
end
