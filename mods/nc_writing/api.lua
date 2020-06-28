-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs, table
    = ItemStack, minetest, nodecore, pairs, table
local table_sort
    = table.sort
-- LUALOCALS > ---------------------------------------------------------

local glyphs = {
	{name = "Cav"},
	{name = "Odo"},
	{name = "Niz"},
	{name = "Zin", flipped = "niz"},
	{name = "Mew"},
	{name = "Fot"},
	{name = "Tof", flipped = "fot"},
	{name = "Yit"},
	{name = "Geq"},
	{name = "Qeg", flipped = "geq"},
	{name = "Prx"},
	{name = "Xrp", flipped = "prx"}
}
nodecore.writing_glyphs = glyphs

local glyph_next = {}
local glyph_alts = {}
for i = 2, #glyphs do
	glyph_next[i - 1] = i
	if #glyphs[i] > #glyphs[1] then
		glyph_next[i - 1] = (i < #glyphs) and i + 1 or 1
		glyph_alts[i] = i - 1
		glyph_alts[i - 1] = i
	end
	glyph_next[#glyphs] = 1
end
nodecore.writing_glyph_next = glyph_next
nodecore.writing_glyph_alts = glyph_alts

local spinmap
do
	local rots = {}
	for i = 0, 23 do
		local f = nodecore.facedirs[i]
		local r = rots[f.t.n]
		if not r then
			r = {}
			rots[f.t.n] = r
		end
		r[f.f.n] = i
	end
	spinmap = {}
	for _, v in pairs(rots) do
		local t = {}
		for _, x in pairs(v) do t[#t + 1] = x end
		table_sort(t)
		for i = 1, #t - 1 do
			spinmap[t[i]] = t[i + 1]
		end
		spinmap[t[#t]] = t[1]
	end
end
nodecore.writing_spinmap = spinmap

local function writable(pos, node)
	node = node or minetest.get_node_or_nil(pos)
	if not node then return end
	local def = minetest.registered_nodes[node.name]
	return def.walkable and def.paramtype ~= "light"
	and not nodecore.tool_digs(ItemStack(""), def.groups)
end
nodecore.writing_writable = writable
