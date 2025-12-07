local ffi = zune.ffi
local fs = zune.fs
local raylib = require("./raylib")
local text = require("./text")
local const = raylib
local structs = raylib.structs

local void = ffi.types.void
local int = ffi.types.i32
local uint = ffi.types.u32
local bool = ffi.types.u8
local float = ffi.types.float
local cstring = ffi.types.pointer
local long = ffi.types.i64
type int = number
type uint = number
type bool = number
type float = number
type long = buffer
type double = number
type cstring = string | buffer | FFIPointer
local Vector2 = structs.Vector2
local Vector3 = structs.Vector3
local Rectangle = structs.Rectangle
local Color = structs.Color
local Font = structs.Font

type Rectangle = typeof(structs.Rectangle:new({}))

type font = typeof(structs.Font:new({}))
type Vector2 = typeof(Vector2)
type Color = typeof(structs.Color:new({}))
type Vector3 = FFIVectorType

local function fn(returns: any, args: { any })
	return {
		returns = returns,
		args = args,
	}
end

export type Fns = {
	GuiEnable: () -> (),
	GuiDisable: () -> (),
	GuiLock: () -> (),
	GuiUnlock: () -> (),
	GuiIsLocked: () -> bool,
	GuiSetAlpha: (alpha: float) -> (),

	GuiSetFont: (font: font) -> (),
	GuiGetFont: () -> int,

	GuiSetStyle: (control: int, property: int, value: int) -> (),
	GuiGetStyle: (control: int, property: int) -> int,

	GuiLoadStyle: (fileName: cstring) -> (),
	GuiLoadStyleDefault: () -> (),

	GuiEnableTooltip: () -> (),
	GuiDisableTooltip: () -> (),
	GuiSetTooltip: (tooltip: cstring) -> (),

	GuiIconText: (IconId: int, text: cstring) -> cstring,
	GuiSetIconScale: (scale: int) -> (),
	GuiGetIcons: () -> uint,
	GuiLoadIcons: (fileName: cstring, loadIconsName: boolean) -> cstring,
	GuiDrawIcons: (iconId: int, posX: int, posY: int, pixelSize: int, color: raylib.Color) -> (),
	GuiGetTextWidth: (text: cstring) -> int,

	GuiWindowBox: (bounds: Rectangle, title: cstring) -> int,
	GuiGroupBox: (bounds: Rectangle, text: cstring) -> int,
	GuiLine: (bounds: Rectangle, text: cstring) -> int,
	GuiPanel: (bounds: Rectangle, text: cstring) -> int,
	GuiTabBar: (bounds: Rectangle, text: cstring, count: int, active: FFIPointer) -> int,
	GuiScrollPanel: (bounds: Rectangle, text: cstring, content: Rectangle, scroll: Vector2, view: Rectangle) -> int,

	GuiLabel: (bounds: Rectangle, text: cstring) -> int,
	GuiButton: (bounds: Rectangle, text: cstring) -> int,
	GuiLabelButton: (bounds: Rectangle, text: cstring) -> int,
	GuiToggle: (bounds: Rectangle, text: cstring, active: bool) -> int,
	GuiToggleGroup: (bounds: Rectangle, text: cstring, active: int) -> int,
	GuiToggleSlider: (bounds: Rectangle, text: cstring, active: int) -> int,
	GuiCheckBox: (bounds: Rectangle, text: cstring, checked: bool) -> int,
	GuiComboBox: (bounds: Rectangle, text: cstring, active: int) -> int,

	GuiDropdownBox: (bounds: Rectangle, text: cstring, active: int, editMode: bool) -> int,
	GuiSpinner: (bounds: Rectangle, text: cstring, value: int, minValue: int, maxValue: int, editMode: bool) -> int,
	GuiValueBox: (bounds: Rectangle, text: cstring, value: int, minValue: int, maxValue: int, editMode: bool) -> int,
	GuiValueBoxFloat: (bounds: Rectangle, text: cstring, textValue: cstring, value: float, editMode: bool) -> int,
	GuiTextBox: (bounds: Rectangle, text: cstring, textSize: int, editMode: bool) -> int,

	GuiSlider: (
		bounds: Rectangle,
		textLeft: cstring,
		textRight: cstring,
		value: float,
		minValue: float,
		maxValue: float
	) -> int,
	GuiSliderBar: (
		bounds: Rectangle,
		textLeft: cstring,
		textRight: cstring,
		value: float,
		minValue: float,
		maxValue: float
	) -> int,
	GuiProgressBar: (
		bounds: Rectangle,
		textLeft: cstring,
		textRight: cstring,
		value: float,
		minValue: float,
		maxValue: float
	) -> int,
	GuiStatusBar: (bounds: Rectangle, text: cstring) -> int,
	GuiDummyRec: (bounds: Rectangle, text: cstring) -> int,
	GuiGrid: (bounds: Rectangle, text: cstring, spacing: float, subdivs: int, mouseCell: Vector2) -> int,

	GuiListView: (bounds: Rectangle, text: cstring, scrollIndex: int, active: int) -> int,
	GuiListViewEx: (bounds: Rectangle, text: cstring, count: int, scrollIndex: int, active: int, focus: int) -> int,
	GuiMessageBox: (bounds: Rectangle, title: cstring, message: cstring, buttons: cstring) -> int,
	GuiTextInputBox: (
		bounds: Rectangle,
		title: cstring,
		message: cstring,
		buttons: cstring,
		text: cstring,
		textMaxSize: int,
		secretViewActive: bool
	) -> int,
	GuiColorPicker: (bounds: Rectangle, text: cstring, color: Color) -> int,
	GuiColorPanel: (bounds: Rectangle, text: cstring, color: Color) -> int,
	GuiColorBarAlpha: (bounds: Rectangle, text: cstring, alpha: float) -> int,
	GuiColorBarHue: (bounds: Rectangle, text: cstring, value: float) -> int,
	GuiColorPickerHSV: (bounds: Rectangle, text: cstring, colorHSV: Vector3) -> int,
	GuiColorPanelHSV: (bounds: Rectangle, text: cstring, colorHSV: Vector3) -> int,
}

return {
	def = {
		GuiEnable = fn(void, {}),
		GuiDisable = fn(void, {}),
		GuiLock = fn(void, {}),
		GuiUnlock = fn(void, {}),
		GuiIsLocked = fn(void, {}),
		GuiSetAlpha = fn(void, { float }),
		GuiSetState = fn(void, { int }),
		GuiGetState = fn(int, {}),

		GuiSetFont = fn(void, { Font }),
		GuiGetFont = fn(int, {}),

		GuiSetStyle = fn(void, { int, int, int }),
		GuiGetStyle = fn(int, { int, int }),

		GuiLoadStyle = fn(void, { cstring }),
		GuiLoadStyleDefault = fn(void, {}),

		GuiEnableTooltip = fn(void, {}),
		GuiDisableTooltip = fn(void, {}),
		GuiSetTooltip = fn(void, { cstring }),

		GuiIconText = fn(cstring, { int, cstring }),
		-- GuiSetIconScale = fn(void, {int}),
		-- GuiGetIcons = fn(uint, {}),
		-- GuiLoadIcons = fn(cstring, {cstring, bool}),
		-- GuiDrawIcons = fn(void, {int, int, int, int, Color}),
		GuiGetTextWidth = fn(int, { cstring }),

		GuiWindowBox = fn(int, { Rectangle, cstring }),
		GuiGroupBox = fn(int, { Rectangle, cstring }),
		GuiLine = fn(int, { Rectangle, cstring }),
		GuiPanel = fn(int, { Rectangle, cstring }),
		GuiTabBar = fn(int, { Rectangle, cstring, int, ffi.types.pointer }),
		GuiScrollPanel = fn(int, { Rectangle, cstring, Rectangle, Vector2, Rectangle }),

		GuiLabel = fn(int, { Rectangle, cstring }),
		GuiButton = fn(int, { Rectangle, cstring }),
		GuiLabelButton = fn(int, { Rectangle, cstring }),
		GuiToggle = fn(int, { Rectangle, cstring, bool }),
		GuiToggleGroup = fn(int, { Rectangle, cstring, int }),
		GuiToggleSlider = fn(int, { Rectangle, cstring, int }),
		GuiCheckBox = fn(int, { Rectangle, cstring, bool }),
		GuiComboBox = fn(int, { Rectangle, cstring, int }),

		GuiDropdownBox = fn(int, { Rectangle, cstring, int, bool }),
		GuiSpinner = fn(int, { Rectangle, cstring, int, int, int, bool }),
		GuiValueBox = fn(int, { Rectangle, cstring, int, int, int, bool }),
		GuiValueBoxFloat = fn(int, { Rectangle, cstring, cstring, float, bool }),
		GuiTextBox = fn(int, { Rectangle, cstring, int, bool }),

		GuiSlider = fn(int, { Rectangle, cstring, cstring, float, float, float }),
		GuiSliderBar = fn(int, { Rectangle, cstring, cstring, float, float, float }),
		GuiProgressBar = fn(int, { Rectangle, cstring, cstring, float, float, float }),
		GuiStatusBar = fn(int, { Rectangle, cstring }),
		GuiDummyRec = fn(int, { Rectangle, cstring }),
		GuiGrid = fn(int, { Rectangle, cstring, float, int, Vector2 }),

		GuiListView = fn(int, { Rectangle, cstring, int, int }),
		GuiListViewEx = fn(int, { Rectangle, cstring, int, int, int, int }),
		GuiMessageBox = fn(int, { Rectangle, cstring, cstring, cstring }),
		GuiTextInputBox = fn(int, { Rectangle, cstring, cstring, cstring, cstring, int, bool }),
		GuiColorPicker = fn(int, { Rectangle, cstring, Color }),
		GuiColorPanel = fn(int, { Rectangle, cstring, Color }),
		GuiColorBarAlpha = fn(int, { Rectangle, cstring, float }),
		GuiColorBarHue = fn(int, { Rectangle, cstring, float }),
		GuiColorPickerHSV = fn(int, { Rectangle, cstring, Vector3 }),
		GuiColorPanelHSV = fn(int, { Rectangle, cstring, Vector3 }),
	},
}
