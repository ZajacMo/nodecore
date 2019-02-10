-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, type
    = ipairs, minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local function craftcheck(recipe, pos, node, data, xx, xz, zx, zz)
	local function rel(x, y, z)
		return {
			x = pos.x + xx * x + zx * z,
			y = pos.y + y,
			z = pos.z + xz * x + zz * z
		}
	end
	local function wield()
		local w = data.crafter and data.crafter:get_wielded_item()
		wield = function() return w end
		return w
	end
	if recipe.check and not recipe.check(pos, data, rel) then return end
	if recipe.wield and (not wield() or not nodecore.match(
			{stack = wield()}, recipe.wield)) then return end
	if recipe.normal then
		if data.pointed.type ~= "node" or
		recipe.normal.y ~= data.pointed.above.y - data.pointed.under.y then return end
		local rx = recipe.normal.x * xx + recipe.normal.z * zx
		if rx ~= data.pointed.above.x - data.pointed.under.x then return end
		local rz = recipe.normal.x * xz + recipe.normal.z * zz
		if rz ~= data.pointed.above.z - data.pointed.under.z then return end
	end
	local mindur = recipe.duration or 0
	if recipe.toolgroups then
		if not wield() then return end
		local dg = wield():get_tool_capabilities().groupcaps
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
	if mindur > 0 and (not data.duration or data.duration < mindur) then
		if data.inprogress then return data.inprogress(data, recipe) end
		return
	end
	for _, v in pairs(recipe.nodes) do
		if v ~= recipe.root and v.match then
			local p = rel(v.x, v.y, v.z)
			if not nodecore.match(p, v.match) then return end
		end
	end
	for _, v in pairs(recipe.nodes) do
		if v.replace then
			local p = rel(v.x, v.y, v.z)
			local r = v.replace
			while type(r) == "function" do
				r = r(p, v)
			end
			if r and type(r) == "string" then
				r = {name = r}
			end
			if r then minetest.set_node(p, r) end
		end
	end
	if recipe.items then
		for _, v in pairs(recipe.items) do
			nodecore.item_eject(rel(v.x or 0, v.y or 0, v.z or 0), v, recipe.itemscatter)
		end
	end
	if recipe.consumewield then
		nodecore.consume_wield(data.crafter, recipe.consumewield)
	elseif recipe.toolgroups and recipe.toolwear and data.crafter then
		nodecore.wear_wield(data.crafter, recipe.toolgroups, recipe.toolwear)
	end
	if recipe.after then recipe.after(pos, rel, data) end
	minetest.log((data.crafter and data.crafter:get_player_name() or "unknown")
		.. " completed recipe \"" .. recipe.label .. "\" at " ..
		minetest.pos_to_string(pos) .. " upon " .. node.name)
	return true
end

function nodecore.craft_check(pos, node, data)
	data = data or {}
	local function go(rc, xx, xz, zx, zz)
		return craftcheck(rc, pos, node, data, xx, xz, zx, zz)
	end
	node.x = pos.x
	node.y = pos.y
	node.z = pos.z
	for _, rc in ipairs(nodecore.craft_recipes) do
		if nodecore.match(node, rc.root.match) and data.action == rc.action then
			if go(rc, 1, 0, 0, 1) then return true end
			if not rc.norotate then
				if go(rc, 0, -1, 1, 0) then return true end
				if go(rc, -1, 0, 0, -1) then return true end
				if go(rc, 0, 1, -1, 0) then return true end
				if not rc.nomirror then
					if go(rc, -1, 0, 0, 1) then return true end
					if go(rc, 0, 1, 1, 0) then return true end
					if go(rc, 1, 0, 0, -1) then return true end
					if go(rc, 0, -1, -1, 0) then return true end
				end
			end
		end
	end
end
