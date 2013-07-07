print("entry=booting lua")

local lanes = require "lanes".configure()
local linda = lanes.linda()

print("entry=booted lua")

if isMainThread then
	-- can now run everything to boot it
end