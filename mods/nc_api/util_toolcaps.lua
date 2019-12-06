-- LUALOCALS < ---------------------------------------------------------
local math, nodecore, pairs
    = math, nodecore, pairs
local math_pow
    = math.pow
-- LUALOCALS > ---------------------------------------------------------

local basetimes = {
	cracky = 3,
	thumpy = 2,
	choppy = 2,
	crumbly = 0.5,
	snappy = 0.4,
}

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
			gcaps[gn] = {
				times = times,
				uses = 5 * math_pow(3, lv) * opts.uses
			}
		end
	end
	return {groupcaps = gcaps, opts = opts}
end
