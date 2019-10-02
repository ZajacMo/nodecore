-- LUALOCALS < ---------------------------------------------------------
local math, pairs, table
    = math, pairs, table
local math_ceil, math_floor, table_concat, table_sort
    = math.ceil, math.floor, table.concat, table.sort
-- LUALOCALS > ---------------------------------------------------------

local min = {
	x = -192,
	y = -16,
	z = -192
}
local max = {
	x = 64,
	y = 32,
	z = -64
}

for k, v in pairs(min) do min[k] = math_floor(v / 80) * 5 end
for k, v in pairs(max) do max[k] = math_ceil(v / 80) * 5 end

local t = {}
for x = min.x, max.x do
	for y = min.y, max.y do
		for z = min.z, max.z do
			t[#t + 1] = x + 4096 * y + 16777216 * z
		end
	end
end
table_sort(t)

print("create table if not exists keep(id integer primary key);")
print("begin transaction;")
for s = 1, #t, 100 do
	local e = s + 99
	if e > #t then e = #t end
	local u = {}
	for i = s, e do u[#u + 1] = t[i] end
	print("insert into keep(id) values(" .. table_concat(u, "),(") .. ");")
end
print("commit;")
print("delete from blocks where pos not in (select distinct id from keep);")
print("drop table keep;")
print("vacuum;")
