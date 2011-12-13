-- --
-- Requires
-- --
require "class"
require "util"
require "cursor"
require "entities"

require "math"

-- --
-- Constants
-- --
SCREEN_WIDTH = 1366
SCREEN_HEIGHT = 768
GRAVITY = 0.0028
BOUNCINESS = 3
FRICTION = 0
MAXSPEED = 10
SIMSPEED = 20
SCREENWALL = false
PAUSED = false
DEBUG = true

-- --
-- Game
-- --
function reset()
	entities = List:new()
	
	--entities:push(
	--	PointMass:new(Vector2f:new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), 500000)
	--)
	
	entities:push(
		Planet:new(Vector2f:new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), 50)
	)
	
	--entities:push(
	--	Planet:new(Vector2f:new(50, SCREEN_HEIGHT / 2), 25)
	--)
	
	--entities:push(
	--	Planet:new(Vector2f:new(SCREEN_WIDTH - 50, SCREEN_HEIGHT / 2), 25)
	--)
	
	if false then
		for j = 1, 4 do
			for i = 1, 10 do
				local c = Comet:new(Vector2f:new(10, 20 * j), 2, 20)
				c.speed = Vector2f:new(i, 0)
				entities:push(c)
			end
		end
	end
	
	if true then
		for i = 1, 4 do
			for a = 0, 10 do
				local vec = Vector2f:fromAngle(a * (2 * math.pi / 10), 150 + i * 50)
				local c = Comet:new(Vector2f:new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2) + vec, 2, 20)
				c.speed = vec:normalize():scale(5):rotate(math.pi / 2)
				entities:push(c)
			end
		end
	end
	
	if false then
		for i = 1, 9 do
			for j = 1, 9 do
				local c = Comet:new(Vector2f:new(SCREEN_WIDTH / 10 * i, SCREEN_HEIGHT / 10 * j), 6, 20)
				entities:push(c)
			end
		end
	end
	
	cursormodes = List:new()
	cursormodes:push(CM_Attract:new())
	cursormodes:push(CM_Spawner:new())
	cursormodeid = 1
	cursormode = cursormodes:at(cursormodeid)
	cursormodes:forEach(function(e) e:init() end)
	cursormode:start()
end

-- --
-- Love
-- --
function love.load()
	love.graphics.setMode(SCREEN_WIDTH, SCREEN_HEIGHT, false, true, 0)
	love.graphics.setBackgroundColor(110, 140, 250)
	
	reset()
	
	cm_namefont = love.graphics.newFont(14)
	cm_descfont = love.graphics.newFont(10)
end

function love.update(dt)
	if not PAUSED then
		if love.keyboard.isDown("q") then
			SIMSPEED = SIMSPEED + 1
		end
		if love.keyboard.isDown("a") then
			SIMSPEED = SIMSPEED - 1
		end
	end
	if love.keyboard.isDown("w") then
		BOUNCINESS = BOUNCINESS + 0.1
	end
	if love.keyboard.isDown("s") then
		BOUNCINESS = BOUNCINESS - 0.1
	end
	if love.keyboard.isDown("e") then
		MAXSPEED = MAXSPEED + 0.5
	end
	if love.keyboard.isDown("d") then
		MAXSPEED = MAXSPEED - 0.5
		if MAXSPEED < 0 then MAXSPEED = 0 end
	end
	if love.keyboard.isDown("r") then
		GRAVITY = GRAVITY * 1.05
	end
	if love.keyboard.isDown("f") then
		GRAVITY = GRAVITY * 0.95
	end
	if not PAUSED then
		for entity in entities:iter() do
			entity:preupdate(dt * SIMSPEED)
		end
		for entity in entities:iter() do
			entity:update(dt * SIMSPEED)
		end
	end
	cursormode:update(dt * SIMSPEED)
end

function love.draw()
	for entity in entities:iter() do
		entity:draw()
	end
	Color:new(0, 0, 0):set()
	love.graphics.setFont(cm_namefont)
	love.graphics.print(cursormode:name(), 10, 10)
	love.graphics.setFont(cm_descfont)
	love.graphics.print(cursormode:desc(), 10, 30)
	love.graphics.print(cursormode:status(), 10, 40)
	
	local cy = SCREEN_HEIGHT - 15
	local p = function(text)
		love.graphics.print(text, 10, cy)
		cy = cy - 10
	end
	local showbool = function(bool)
		if bool == true then return "true"
		else return "false" end
	end
	p("GRAVITY = " .. GRAVITY)
	p("MAXSPEED = " .. MAXSPEED)
	p("BOUNCINESS = " .. BOUNCINESS)
	p("FRICTION = " .. FRICTION)
	p("SIMSPEED = " .. SIMSPEED)
	p("PAUSED = " .. showbool(PAUSED))
	p("SCREENWALL = " .. showbool(SCREENWALL))
	p("DEBUG = " .. showbool(DEBUG))
	cursormode:draw()
end

function love.keypressed(button)
	if button == "p" then
		reset()
	end
end

function love.keyreleased(button)
	if button == " " then
		if PAUSED then
			PAUSED = false
			SIMSPEED = simspeed_pre
		else
			simspeed_pre = SIMSPEED
			PAUSED = true
			SIMSPEED = 0
		end
	end
	if button == "c" then
		DEBUG = not DEBUG
	end
	if button == "v" then
		GRAVITY = -GRAVITY
	end
	if button == "x" then
		SCREENWALL = not SCREENWALL
	end
	if button == "lctrl" or button == "rctrl" then
		cursormodeid = cursormodeid + 1
		if cursormodeid > cursormodes:length() then
			cursormodeid = 1
		end
		cursormode:stop()
		cursormode = cursormodes:at(cursormodeid)
		cursormode:start()
	end
end
