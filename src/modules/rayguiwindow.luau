return function(raylib, structs)
	local windowRegistry = {}
	local module = {}
	local draggedWindow = nil
	local dragOffset = { x = 0, y = 0 }
	local Color3 = require("@Color3")

	local function Color3ToRaylib(c, transparency)
		local r, g, b = c:ToRGB()
		return structs.Color:new({
			r = r,
			g = g,
			b = b,
			a = math.floor(255 * (1 - transparency)),
		})
	end

	module.OutlineColor = Color3.new(0, 0.517647, 1)
	module.OutlineTransparency = 1
	module.dragged = function() end
	module.stepped = function() end
	module.dragEnd = function() end

	function module.create(data: { step: () -> (), title: string, x: number, y: number, width: number, height: number })
		local window = {
			title = data.title,
			x = data.x,
			y = data.y,
			width = data.width,
			height = data.height,
			id = #windowRegistry + 1,
			stepped = data.step,
			scrollOffset = vector.create(0, 0),
		}
		table.insert(windowRegistry, window)
		return window
	end

	function module.update()
		local mousePos = raylib.GetMousePosition()
		local mousePressed = raylib.IsMouseButtonPressed(0) -- Left mouse button
		local mouseDown = raylib.IsMouseButtonDown(0)
		local mouseReleased = raylib.IsMouseButtonReleased(0)

		if mousePressed == 1 and not draggedWindow then
			for i = #windowRegistry, 1, -1 do
				local window = windowRegistry[i]
				local titleBarHeight = 24

				if
					mousePos.x >= window.x
					and mousePos.x <= window.x + window.width
					and mousePos.y >= window.y
					and mousePos.y <= window.y + titleBarHeight
				then
					draggedWindow = window
					dragOffset.x = mousePos.x - window.x
					dragOffset.y = mousePos.y - window.y

					table.remove(windowRegistry, i)
					table.insert(windowRegistry, window)
					break
				end
			end
		end

		if mouseDown == 1 and draggedWindow then
			draggedWindow.x = mousePos.x - dragOffset.x
			draggedWindow.y = mousePos.y - dragOffset.y
			draggedWindow.IsDragging = true
			module.dragged(draggedWindow)
		end

		if mouseReleased == 1 then
			if draggedWindow then
				draggedWindow.IsDragging = false

				module.dragEnd(draggedWindow)
			end

			draggedWindow = nil
		end
	end

	function module.draw()
		for _, window in pairs(windowRegistry) do
			if window.Closed then
				continue
			end
			local rect = structs.Rectangle:new({
				x = window.x,
				y = window.y,
				width = window.width,
				height = window.height,
			})

			local contentBounds = structs.Rectangle:new({
				x = window.x,
				y = window.y + 24,
				width = window.width,
				height = window.height - 24,
			})

			local contentRect = structs.Rectangle:new({
				x = window.x,
				y = window.y + 24,
				width = window.width,
				height = window.height * 4, -- Make this LARGER than contentBounds.height to enable scrolling
			})

			local viewRect = structs.Rectangle:new({
				x = 0,
				y = 0,
				width = 0,
				height = 0,
			})

			local close = raylib.GuiWindowBox(rect, window.title)
			if close ~= 0 then
				window.Closed = true
			end
			local result = raylib.GuiScrollPanel(contentBounds, nil, contentRect, window.scrollOffset, viewRect)
			if result ~= 0 then
				print(result)
			end
			raylib.BeginScissorMode(window.x, window.y, window.width, window.height)

			module.stepped(window)
			raylib.EndScissorMode()

			if window["stepped"] then
				window.stepped()
			end
		end
	end

	return module
end
