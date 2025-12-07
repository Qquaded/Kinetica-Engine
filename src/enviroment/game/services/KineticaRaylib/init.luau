local Instance = require("@Instance")
local signal = require("@kinetica.signal")

local KineticaRaylib = Instance.new("KineticaRaylib")

KineticaRaylib.InitRenderer = function(renderer, renderer_signal)
	KineticaRaylib:SetProperties({
		lib = renderer.lib,
		const = renderer.const,
		structs = renderer.structs,
		renderer = renderer,
	})
end

return KineticaRaylib
