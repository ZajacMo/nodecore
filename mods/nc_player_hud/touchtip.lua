-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, rawset, tostring, vector
    = ItemStack, math, minetest, nodecore, rawset, tostring, vector
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local countdesc = "@1 (@2)"
nodecore.translate_inform(countdesc)

local weardescs = {"@1"}
for i = 1, 65535 do
	local q = math_floor(i * 5 / 65536 + 0.5)
	local t = "@1 "
	for _ = 1, (5 - q) do t = t .. "|" end
	for _ = 1, q do t = t .. "." end
	weardescs[i] = t
	nodecore.translate_inform(weardescs[i])
end

function nodecore.touchtip_stack(s, noqty)
	if s:is_empty() then return "" end

	local n = s:get_name()
	local d = minetest.registered_items[n] or {}

	local sm = s:get_meta()
	local t = sm:get_string("description")
	t = t ~= "" and t or d.description or n

	if not noqty then
		local c = sm:get_string("count_meta")
		c = c and c ~= "" and c or tostring(s:get_count())
		if c ~= "1" then
			t = nodecore.translate(countdesc,
				nodecore.translate(t), c)
		else
			local w = s:get_wear()
			if w > 1 then
				t = nodecore.translate(t)
				t = nodecore.translate(weardescs[w], t)
			end
		end
	end

	if d.on_stack_touchtip then
		return d.on_stack_touchtip(s, t) or t
	end
	return t
end

local function rawnodedesc(pos, node, name, def, puncher, pointed, ...)
	node = node or minetest.get_node(pos)
	name = name or node.name
	def = def or minetest.registered_items[name] or {}

	local metaname = minetest.get_meta(pos):get_string("description")
	if metaname and metaname ~= "" then
		name = metaname
	elseif def.groups and def.groups.is_stack_only then
		name = nodecore.touchtip_stack(nodecore.stack_get(pos))
	elseif def.description then
		name = def.description
	end

	if def.groups and def.groups.visinv and not def.groups.is_stack_only then
		local s = nodecore.stack_get(pos)
		local t = nodecore.touchtip_stack(s)
		if t and t ~= "" then name = name .. "\n" .. t end
	end

	if def.on_node_touchtip then
		return def.on_node_touchtip(pos, node, name, puncher, pointed, ...) or name
	end
	return name
end

function nodecore.touchtip_node(pos, node, puncher, pointed, ...)
	if not (puncher and puncher:is_player()) then return end

	local adesc = " "
	if pointed and pointed.above and pointed.under
	and vector.equals(pos, pointed.under) then
		local anode = minetest.get_node(pointed.above)
		local def = minetest.registered_items[anode.name] or {}
		if def.on_node_touchthru then
			return def.on_node_touchthru(pointed.above,
				anode, pointed.under, puncher, ...)
		else
			local tt = def.touchthru or def.touchthru ~= false
			and def.liquidtype ~= "none" and not def.pointable

			if tt then
				adesc = rawnodedesc(pointed.above, anode,
					anode.name, def, puncher, pointed, ...)
				local ppos = puncher:get_pos()
				ppos.y = ppos.y + puncher:get_properties().eye_height
				local pnode = minetest.get_node(ppos)
				local pdesc = rawnodedesc(ppos, pnode, pnode.name,
					minetest.registered_items[pnode.name] or {},
					puncher, pointed, ...)
				if adesc == pdesc then adesc = " " end
			end
		end
	end
	node = node or minetest.get_node(pos)
	local name = node.name
	local def = minetest.registered_items[name] or {}
	if def.air_equivalent or def.pointable == false then return end

	return adesc .. "\n" .. rawnodedesc(pos, node,
		name, def, puncher, pointed, ...)
end

nodecore.show_touchtip = function() end

local function adddesc(entname, func)
	local def = minetest.registered_entities[entname]
	rawset(def, "description", func)
end
adddesc("__builtin:item", function(self)
		return nodecore.touchtip_stack(ItemStack(self.itemstring))
	end)
adddesc("__builtin:falling_node", function(self)
		return nodecore.touchtip_stack(ItemStack(self.node.name))
	end)
