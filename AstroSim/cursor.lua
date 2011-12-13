-- --
-- Requires
-- --
require "class"
require "util"
require "entities"

-- --
-- CursorMode
-- --
CursorMode = inherit(Object)

function CursorMode:name()
	return "CursorMode"
end

function CursorMode:desc()
	return ""
end

function CursorMode:status()
	return ""
end

function CursorMode:init()
end

function CursorMode:start()
end

function CursorMode:stop()
end

function CursorMode:update(dt)
end

function CursorMode:draw()
end

-- --
-- Attract
-- --
CM_Attract = inherit(CursorMode)

function CM_Attract:name()
	return "Attract"
end

function CM_Attract:desc()
	return "Press the left and right mouse button to attract and repel objects."
end

function CM_Attract:status()
	return "Gravity: " .. math.floor(self.gravity)
end

function CM_Attract:init()
	self.gravity = 50000
end

function CM_Attract:start()
	self.point = CM_Attract_Point:new(self)
	entities:push(self.point)
end

function CM_Attract:stop()
	entities:remove(self.point)
	self.point = nil
end

function CM_Attract:update(dt)
	if love.keyboard.isDown("left") then
		self.gravity = self.gravity /	1.04
	elseif love.keyboard.isDown("right") then
		self.gravity = self.gravity * 1.04
	end
end

CM_Attract_Point = inherit(PointMass)

function CM_Attract_Point:__init__(cm)
	super(CM_Attract_Point).__init__(self, cursor.getPosition(), 0)
	self.cm = cm
end

function CM_Attract_Point:update(dt)
	self.pos = cursor.getPosition()
end

function CM_Attract_Point:getMass()
	local m = 0
	if love.mouse.isDown("l") then
		m = m + self.cm.gravity
	end
	if love.mouse.isDown("r") then
		m = m - self.cm.gravity
	end
	return m
end

-- --
-- CM_Spawner
-- --
CM_Spawner = inherit(CursorMode)

function CM_Spawner:name()
	return "Comet Spawner"
end

function CM_Spawner:desc()
	return "Click and hold to spawn comets."
end

function CM_Spawner:status()
	return "State: " .. self.state .. " Size: " .. self.size
end

function CM_Spawner:init()
	self.state = "init"
	self.initpos = nil
	self.size = 2
end

function CM_Spawner:update(dt)
	if self.state == "init" then
		if love.mouse.isDown("l") then
			self.initpos = cursor.getPosition()
			self.state = "aim"
		end
	elseif self.state == "aim" then
		if not love.mouse.isDown("l") then
			local c = Comet:new(self.initpos, self.size, 20)
			c.speed = self.initpos:vectorTo(cursor.getPosition()):scale(0.05 * self.size)
			entities:push(c)
			self.state = "init"
		end
	end
	if love.keyboard.isDown("left") then
		self.size = self.size - 1
	elseif love.keyboard.isDown("right") then
		self.size = self.size + 1
	end
end

function CM_Spawner:draw()
	if self.state == "aim" then
		Color:new(0, 0, 255):set()
		self.initpos:vectorTo(cursor.getPosition()):DEBUG_draw(self.initpos)
	end
end
