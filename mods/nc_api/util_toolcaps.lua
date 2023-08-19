-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, nodecore, pairs
    = ItemStack, math, nodecore, pairs
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
nodecore.tool_basetimes = basetimes

for k, v in pairs(basetimes) do
	basetimes[k] = v / nodecore.rate_adjustment("speed", "tool", k)
end

function nodecore.toolcaps(opts)
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

function nodecore.toolspeed(what, groups)
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
		return nodecore.toolspeed(ItemStack(""), groups)
	end
	return t
end
function nodecore.tool_digs(what, groups)
	local s = nodecore.toolspeed(what, groups)
	return s and s <= 4
end

function nodecore.toolheadspeed(what, groups)
	return nodecore.toolspeed({
			get_tool_capabilities = function()
				return what:get_definition().tool_head_capabilities
				or ItemStack(""):get_tool_capabilities()
			end
		}, groups)
end
function nodecore.tool_head_digs(what, groups)
	local s = nodecore.toolheadspeed(what, groups)
	return s and s <= 4
end
