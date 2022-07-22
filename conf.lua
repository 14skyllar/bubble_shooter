function love.conf(t)
	t.modules.audio = true
	t.modules.data = true
	t.modules.event = true
	t.modules.font = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = false
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = false
	t.modules.sound = true
	t.modules.system = true
	t.modules.thread = true
	t.modules.timer = true
	t.modules.touch = true
	t.modules.video = false
	t.modules.window = true

	t.window.title = "Element Master Splash Chemical Bonding Periodic Table Bubble Shooter"

	-- 1080 x 1920
	t.window.width = 1080/3 --360
	t.window.height = 1920/3 --480
	t.window.resizable = false
	t.console = true

	t.identity = "EMSCBPTBS"
	t.version = "11.3"
end

