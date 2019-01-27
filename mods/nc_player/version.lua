local ver = "$Format:%at-%h$"

ver = (ver:sub(1, 1) == "$")
and "DEVELOPMENT VERSION"
or ("Version " .. ver)

return ver
