-- LUALOCALS < ---------------------------------------------------------
local core, nc, tonumber
    = core, nc, tonumber
-- LUALOCALS > ---------------------------------------------------------

local function destroyparticles(name, def, pos)
	def = core.registered_nodes[name] or def
	nc.digparticles(def, {
			time = 0.05,
			amount = tonumber(def.destroy_on_dig) or 50,
			minpos = {x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5},
			maxpos = {x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5},
			minvel = {x = -2, y = -2, z = -2},
			maxvel = {x = 2, y = 2, z = 2},
			minacc = {x = 0, y = -8, z = 0},
			maxacc = {x = 0, y = -8, z = 0},
			minexptime = 0.25,
			maxexptime = 0.5,
			collisiondetection = true,
			collision_removal = true,
			minsize = 1,
			maxsize = 6
		})
end

function nc.node_destroy_effect(pos, node)
	node = node or core.get_node(pos)
	return destroyparticles(node.name, nil, pos)
end

nc.register_on_register_item(function(name, def)
		if def.destroy_on_dig then
			def.after_dig_node = def.after_dig_node or function(pos)
				return destroyparticles(name, def, pos)
			end
		end
	end)
