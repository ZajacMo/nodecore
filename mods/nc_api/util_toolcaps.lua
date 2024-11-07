-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, nc, pairs
    = ItemStack, math, nc, pairs
local math_pow
    = math.pow
-- LUALOCALS > ---------------------------------------------------------

local basetimes = {
	cracky = 3,
	thumpy = 2,
	choppy = 2,
	crumbly = 0.5,
	snappy = 0.4,
	scratchy = 2,
	cuddly = 2
}
nc.tool_basetimes = basetimes

function nc.toolcaps(opts)
	if opts.uses == nil then opts.uses = 1 end
	local gcaps = {}
	for gn, bt in pairs(basetimes) do
		local lv = opts[gn]
		if lv then
			local times = {}
			for n = 1, lv do
				local tt = math_pow(0.5, lv - n) * bt
				if tt < 0.25 then tt = 0.25 end
				times[n] = tt
			end
			local calcuse = 5 * math_pow(3, lv) * opts.uses
			local umin = opts.usesmin or 1
			if umin < 1 then umin = 1 end
			if opts.uses > 0 and calcuse < umin then calcuse = umin end
			gcaps[gn] = {
				times = times,
				uses = calcuse
			}
		end
	end
	return {groupcaps = gcaps, opts = opts, punch_attack_uses = 0}
end

function nc.toolspeed(what, groups)
	if not what then return end
	local dg = what:get_tool_capabilities().groupcaps
	local t
	for gn, lv in pairs(groups) do
		local gt = dg[gn]
		gt = gt and gt.times
		gt = gt and gt[lv]
		if gt and (not t or t > gt) then t = gt end
	end
	if (not t) and (not what:is_empty()) then
		return nc.toolspeed(ItemStack(""), groups)
	end
	return t
end
function nc.tool_digs(what, groups)
	return nc.toolspeed(what, groups)
end

function nc.toolheadspeed(what, groups)
	return nc.toolspeed({
			get_tool_capabilities = function()
				return what:get_definition().tool_head_capabilities
				or ItemStack(""):get_tool_capabilities()
			end
		}, groups)
end
function nc.tool_head_digs(what, groups)
	return nc.toolheadspeed(what, groups)
end
