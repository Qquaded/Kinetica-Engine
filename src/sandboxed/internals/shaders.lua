local KineticaShaderService = game:GetService("KineticaShaderService")
local fs = zune.fs

local entries = fs.entries
for _, shaderFolder in pairs(entries("./src/shaders")) do
	local shader_path = "./src/shaders/" .. shaderFolder.name .. "/"

	local fragment, vertex

	for _, file in pairs(entries(shader_path)) do
		local isFragment = file.name:match(".frag")
		local isVertex = file.name:match(".vert")
		local filePath = shader_path .. file.name

		if isFragment then
			fragment = filePath
		elseif isVertex then
			vertex = filePath
		end
		print(fragment, vertex)
	end
	KineticaShaderService.LoadShader(shaderFolder.name, vertex, fragment)
end
