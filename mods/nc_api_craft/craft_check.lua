-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, error, ipairs, math, nc, pairs, type
    = ItemStack, core, error, ipairs, math, nc, pairs, type
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local function addgroups(sum, pos)
	local node = core.get_node(pos)
	local def = core.registered_items[node.name] or {}
	if not def.groups then return end
	for k, v in pairs(def.groups) do
		sum[k] = (sum[k] or 0) + v
	end
end

local function craftcheck(recipe, pos, node, data, xx, xz, zx, zz)
	local function rel(x, y, z)
		return {
			x = pos.x + xx * x + zx * z,
			y = pos.y + y,
			z = pos.z + xz * x + zz * z
		}
	end
	data.rel = rel
	data.wield = ItemStack(data.wield or data.crafter and data.crafter:get_wielded_item())
	if recipe.check and not recipe.check(pos, data) then return end
	if recipe.wield and (not data.wield or not nc.match(
			{stack = data.wield}, recipe.wield)) then return end
	if recipe.normal then
		if data.pointed.type ~= "node" or
		recipe.normal.y ~= data.pointed.above.y - data.pointed.under.y then return end
		local rx = recipe.normal.x * xx + recipe.normal.z * zx
		if rx ~= data.pointed.above.x - data.pointed.under.x then return end
		local rz = recipe.normal.x * xz + recipe.normal.z * zz
		if rz ~= data.pointed.above.z - data.pointed.under.z then return end
	end
	for _, v in pairs(recipe.nodes) do
		if v.match then
			local p = rel(v.x, v.y, v.z)
			if not nc.match(p, v.match) then return end
		end
	end
	if recipe.heat then
		data.heat = data.heat or core.get_node_heat(pos)
		if recipe.heat > 0 then
			if data.heat < recipe.heat then return end
		elseif recipe.heat < 0 then
			if data.heat >= 0 then return end
		else
			if data.heat ~= 0 then return end
		end
	end
	if recipe.touchgroups then
		local sum = data.touchgroups
		if not sum then
			sum = {}
			addgroups(sum, rel(1, 0, 0))
			addgroups(sum, rel(-1, 0, 0))
			addgroups(sum, rel(0, 1, 0))
			addgroups(sum, rel(0, -1, 0))
			addgroups(sum, rel(0, 0, 1))
			addgroups(sum, rel(0, 0, -1))
			if data.touchgroupmodify then
				data.touchgroupmodify(sum)
			end
			data.touchgroups = sum
		end
		for k, v in pairs(recipe.touchgroups) do
			local w = sum[k] or 0
			if v > 0 and w < v then return end
			if v <= 0 and w > -v then return end
		end
	end
	if recipe.neargroups then
		local sum = data.neargroups
		if not sum then
			sum = {}
			for dx = -1, 1 do
				for dz = -1, 1 do
					for dy = -1, 1 do
						addgroups(sum, rel(dx, dy, dz))
					end
				end
			end
			if data.neargroupmodify then
				data.neargroupmodify(sum)
			end
			data.neargroups = sum
		end
		for k, v in pairs(recipe.neargroups) do
			local w = sum[k] or 0
			if v > 0 and w < v then return end
			if v <= 0 and w > -v then return end
		end
	end
	local mindur = recipe.duration or 0
	if type(mindur) == "function" then mindur = mindur(recipe, pos, node, data) end
	if recipe.toolgroups then
		local dg = data.toolgroupcaps or (data.wield
			and data.wield:get_tool_capabilities().groupcaps)
		if not dg then return end
		local t
		for gn, lv in pairs(recipe.toolgroups) do
			local gt = dg[gn]
			gt = gt and gt.times
			gt = gt and gt[lv]
			if gt and (not t or t > gt) then t = gt end
		end
		if not t then return end
		mindur = mindur + t
	end
	if mindur > 0 then
		if not data.duration then return end
		local dur = data.duration
		if type(dur) == "function" then dur = dur(pos, data) end
		if not dur or dur < mindur then
			if recipe.inprogress then recipe.inprogress(pos, data) end
			if data.inprogress then data.inprogress(pos, data) end
			return false
		end
	end
	return function()
		if data.before then data.before(pos, data) end
		if recipe.before then recipe.before(pos, data) end
		for _, v in ipairs(recipe.nodes) do
			if v.replace and ((not v.chance)
				or (math_random(1, v.chance) == 1)) then
				local p = rel(v.x, v.y, v.z)
				local r = v.replace
				while type(r) == "function" do
					r = r(p, v)
				end
				if r and type(r) == "string" then
					r = {name = r}
				end
				if v.match.excess then
					local s = nc.stack_get(p)
					local x = s:get_count() - (v.match.count or 1)
					if x > 0 then
						s:set_count(x)
						nc.item_eject(p, s)
					end
					nc.stack_set(p, ItemStack(""))
				end
				if r then
					if not r.param2 then
						local rd = core.registered_nodes[r.name]
						if rd and rd.paramtype2 == "facedir" then
							r.param2 = math_random(0, 3)
						else
							local n = core.get_node(p)
							r.param2 = n.param2
						end
					end
					nc.set_loud(p, r)
					nc.fallcheck(p)
				end
			end
			if v.dig then
				local p = rel(v.x, v.y, v.z)
				core.node_dig(p, core.get_node(p))
			end
		end
		if recipe.items then
			for _, v in pairs(recipe.items) do
				nc.item_eject(rel(v.x or 0, v.y or 0, v.z or 0),
					v.name, v.scatter, v.count, v.velocity)
			end
		end
		if recipe.consumewield and data.crafter then
			nc.consume_wield(data.crafter, recipe.consumewield)
		elseif recipe.toolgroups and recipe.toolwear and data.crafter then
			nc.wear_wield(data.crafter, recipe.toolgroups, recipe.toolwear)
		end
		if recipe.after then recipe.after(pos, data) end
		if data.after then data.after(pos, data) end
		local discover = {recipe.action, recipe.label, data.discover, recipe.discover}
		nc.player_discover(data.crafter, discover, "craft:")
		if data.witness or recipe.witness then
			nc.witness(pos, discover)
			for _, v in pairs(recipe.nodes) do
				if v.x ~= 0 or v.y ~= 0 or v.z ~= 0 then
					nc.witness(rel(v.x, v.y, v.z), discover)
				end
			end
		end
		local pname = data.crafter and data.crafter:get_player_name()
		nc.log(pname and "action" or "info", (pname or "unknown")
			.. " crafts \"" .. recipe.label .. "\" at " ..
			core.pos_to_string(pos))
	end
end

local function tryall(rc, pos, node, data)
	local function go(xx, xz, zx, zz)
		return craftcheck(rc, pos, node, data, xx, xz, zx, zz)
	end
	local r = go(1, 0, 0, 1)
	if r then return r end
	if not rc.norotate then
		r = go(0, -1, 1, 0)
		or go(-1, 0, 0, -1)
		or go(0, 1, -1, 0)
		if r then return r end
		if not rc.nomirror then
			r = go(-1, 0, 0, 1)
			or go(0, 1, 1, 0)
			or go(1, 0, 0, -1)
			or go(0, -1, -1, 0)
		end
	end
	return r
end

local craftidx, rebuildidx = nc.item_matching_index(
	nc.registered_recipes,
	function(i) return i.indexkeys or {true} end,
	"register_craft",
	true,
	function(n, i) return i.action .. "|" .. n end
)

do
	local dirty
	local oldreg = nc.register_craft
	local function rebuildhelper(...)
		if not dirty then
			dirty = true
			core.after(0, function()
					dirty = nil
					rebuildidx()
				end)
		end
		return ...
	end
	function nc.register_craft(...)
		return rebuildhelper(oldreg(...))
	end
end

local function checkall(pos, node, data, set)
	for _, rc in ipairs(set) do
		if data.action == rc.action
		and nc.match(node, rc.root.match) then
			data.recipe = rc
			if data.rootmatch then data.rootmatch(data) end
			local r = tryall(rc, pos, node, data)
			if r == false then return end
			if r then return r end
		end
	end
end

function nc.craft_search(pos, node, data)
	if not data or not data.action then
		return error("craft_check without data.action")
	end

	node.x = pos.x
	node.y = pos.y
	node.z = pos.z
	data.pos = pos
	data.node = node

	local seen = {}
	if node and node.name then
		local key = data.action .. "|" .. node.name
		local set = craftidx[key]
		if set then
			local found = checkall(pos, node, data, set)
			if found then return found end
			for _, i in pairs(set) do seen[i] = true end
		end
	end

	local stack = pos and nc.stack_get(pos)
	if not stack:is_empty() then
		local key = data.action .. "|" .. stack:get_name()
		local set = craftidx[key]
		if set then
			local unique = {}
			for _, i in ipairs(set) do
				if not seen[i] then unique[#unique + 1] = i end
			end
			if #unique > 0 then
				local found = checkall(pos, node, data, unique)
				if found then return found end
			end
		end
	end
end

function nc.craft_check(...)
	local commit = nc.craft_search(...)
	if not commit then return end
	commit()
	return true
end
