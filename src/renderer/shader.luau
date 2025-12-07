return function(lib, loopshader, lighting, const, cameraPos, activeLights, SetShaderUniform, time)
	loopshader(function(shaderName, activeShader)
		lib.BeginShaderMode(activeShader)

		SetShaderUniform(activeShader, "time", time, const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT)
		SetShaderUniform(
			activeShader,
			"viewPos",
			{ cameraPos.x, cameraPos.y, cameraPos.z },
			const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
		)

		if lighting then
			local ambient = lighting.Ambient
			SetShaderUniform(
				activeShader,
				"globalAmbient",
				{ ambient.R / 255, ambient.G / 255, ambient.B / 255 },
				const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
			)

			local sunDir = lighting:GetSunDirection()
			SetShaderUniform(
				activeShader,
				"dirLightDir",
				{ -sunDir.X, -sunDir.Y, -sunDir.Z },
				const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
			)
			SetShaderUniform(
				activeShader,
				"dirLightColor",
				{ 1.0, 0.95, 0.8 },
				const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
			)
		end

		local positions, colors, intensities = {}, {}, {}
		for i, light in ipairs(activeLights) do
			positions[i] = light.pos
			colors[i] = light.color
			intensities[i] = light.intensity
		end

		SetShaderUniform(activeShader, "pointLightCount", #activeLights, const.ShaderUniformDataType.SHADER_UNIFORM_INT)
		SetShaderUniform(
			activeShader,
			"pointLightPositions",
			positions,
			const.ShaderUniformDataType.SHADER_UNIFORM_VEC3_ARRAY
		)
		SetShaderUniform(
			activeShader,
			"pointLightColors",
			colors,
			const.ShaderUniformDataType.SHADER_UNIFORM_VEC3_ARRAY
		)
		SetShaderUniform(
			activeShader,
			"pointLightIntensities",
			intensities,
			const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT_ARRAY
		)
	end)
end
