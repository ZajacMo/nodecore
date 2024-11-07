-- LUALOCALS < ---------------------------------------------------------
local core, include, ipairs, nc, pairs, string, table, type
    = core, include, ipairs, nc, pairs, string, table, type
local string_format, string_match, table_concat, table_sort
    = string.format, string.match, table.concat, table.sort
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local strings = {}
local strings_dirty

local loadtimeover
core.register_on_mods_loaded(function() loadtimeover = true end)

local prefix = core.translate(modname, "x")
prefix = prefix:sub(1, prefix:find(modname) - 1)

local passthru = "@1"

function nc.translate_inform(str)
	if (not str) or (type(str) ~= "string") or (not string_match(str, "%S"))
	or (str:sub(1, #prefix) == prefix) then return end

	if str == passthru then return true end

	if not strings[str] then
		if loadtimeover then
			nc.log("warning", string_format(
					"Translation string informed late: %q",
					str))
		end
		strings[str] = true
		strings_dirty = true
	end

	return true
end

for _, v in pairs(include('pkgmeta')) do
	nc.translate_inform(v(true))
	nc.translate_inform(v(false))
end

function nc.translate(str, ...)
	if not nc.translate_inform(str) then return str end
	return core.translate(modname, str, ...)
end

function nc.notranslate(str)
	return nc.translate(passthru, str)
end

if nc.infodump() then
	nc.register_globalstep(function()
			if not strings_dirty then return end
			strings_dirty = nil

			local keys = {}
			for k in pairs(strings) do keys[#keys + 1] = k end
			table_sort(keys)

			local trdata = {"# textdomain: " .. modname}
			local podata = {}
			for _, k in ipairs(keys) do
				trdata[#trdata + 1] = k .. "=" .. "\n"
				podata[#podata + 1] = "msgid \"" .. k .. "\"\nmsgstr \"" .. k .. "\"\n"
			end

			core.safe_file_write(
				core.get_worldpath() .. "/" .. modname .. ".template.tr",
				table_concat(trdata, "\n"))
			core.safe_file_write(
				core.get_worldpath() .. "/" .. modname .. ".template.po",
				table_concat(podata, "\n"))
		end)
end

nc.translated_stats = include("translated")
