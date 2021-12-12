-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_abs
    = math.abs
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_globalstep("gametime", function(dtime)
		local mtt = minetest.get_gametime()
		local nct = nodecore.gametime
		if not nct then
			nodecore.log("info", "nodecore.gametime: init to " .. mtt)
			nct = mtt
		end
		nct = nct + dtime
		if math_abs(nct - mtt) >= 2 then
			nodecore.log("warning", "nodecore.gametime: excess drift; nct="
				.. nct .. ", mtt=" .. mtt)
			nct = mtt
		end
		nodecore.gametime = nct
	end)
