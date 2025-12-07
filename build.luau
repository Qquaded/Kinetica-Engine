--!strict
local fs = zune.fs
local process = zune.process

local function build()
	local res = process.run(fs.getExePath(), {
		"bundle",
		"-f",
		"./**/.luaurc",
		"-s",
		"src/main.lua",
		"src/enviroment/**/*.lua*",
		"src/modules/**/*.lua*",
		"src/renderer/**/*.lua*",
		"src/sandboxed/**/*.lua*",
		"src/external/signal.lua",
		"--out=./game-binary",
	})

	if not res.ok then
		error(`\n- {res.stderr}`)
	end
end

build()
