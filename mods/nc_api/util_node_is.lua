-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

function nodecore.buildable_to(node_or_pos)
	return nodecore.match(node_or_pos, {buildable_to = true})
end
