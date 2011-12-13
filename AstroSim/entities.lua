-- --
-- Comet
-- --
Comet = inherit(Object)
Comet.solid = true

function Comet:__init__(pos, size, tailLength)
	self.pos = pos
	self.tailLength = tailLength
	self.speed = Vector2f:new(0.0, 0.0)
	self.size = size
	self.tail = List:new()
end

function Comet:preupdate(dt)
	self.tail:push(self.pos:copy())
	if self.tail:length() > self.tailLength then
		self.tail:popStart()
	end
	for obj in entities:iter() do
		if not (obj == self) then
			local vecTo = self.pos:vectorTo(obj.pos)
			if vecTo:length() > self.size + obj.size then
				local strength = GRAVITY * ((self:getMass() * obj:getMass()) / math.pow(vecTo:length(), 2))
				local gvec = vecTo:normalize():scale(strength)
				self.speed = self.speed + gvec
			end
		end
	end
	for obj in entities:iter() do
		if not (obj == self) and obj.solid then
			local vecTo = self.pos:vectorTo(obj.pos)
			if vecTo:length() <= self.size + obj.size then
				if obj.class == Planet then
					entities:remove(self)
				elseif obj.class == Comet then
					local pos = self.pos + self.pos:vectorTo(obj.pos):scale(self.size / (self.size + obj.size))
					local v1 = math.sqrt(self.size) / math.pi
					local v2 = math.sqrt(obj.size) / math.pi
					print(v1 .. ", " .. v2 .. ", " .. math.pow(v1 + v2, 2) * math.pi)
					local c = Comet:new(pos, math.pow(v1 + v2, 2) * math.pi, (self.tailLength + obj.tailLength) / 2)
					c.speed = (self.speed + obj.speed):scale(0.5)
					entities:remove(self)
					entities:remove(obj)
					entities:push(c)
				else
					self.speed = self.speed:mirrorAround(vecTo):normalize():scale(-self.speed:length() * BOUNCINESS)
				end
			end
		end
	end
	self.speed = self.speed - (self.speed * FRICTION)
	if SCREENWALL then
		if self.pos.x > SCREEN_WIDTH or self.pos.x < 0 then
			self.speed = self.speed:mirrorX()
			if self.pos.x > SCREEN_WIDTH then self.pos.x = SCREEN_WIDTH end
			if self.pos.x < 0 then self.pos.x = 0 end
		end
		if self.pos.y > SCREEN_HEIGHT or self.pos.y < 0 then
			self.speed = self.speed:mirrorY()
			if self.pos.y > SCREEN_HEIGHT then self.pos.y = SCREEN_HEIGHT end
			if self.pos.y < 0 then self.pos.y = 0 end
		end
	end
	if self.speed:length() > MAXSPEED then
		self.speed = self.speed:normalize():scale(MAXSPEED)
	end
end

function Comet:update(dt)
	for obj in entities:iter() do
		if not (obj == self) and obj.solid then
			local vecTo = self.pos:vectorTo(obj.pos)
			if vecTo:length() <= self.size + obj.size then
				self.pos = obj.pos - vecTo
			end
		end
	end
	self.pos = self.pos + self.speed:scale(dt)
end

function Comet:draw()
	Color:new(0, 0, 255):set()
	for i = 1, self.tail:length() do
		local obj = self.tail:at(i)
		gfx.drawCircle("fill", obj, (i / self.tail:length()) * self.size)
	end
	Color:new(255, 0, 255):set()
	gfx.drawCircle("fill", self.pos, self.size)
	if DEBUG then
		for obj in entities:iter() do
			if not (obj == self) then
				local vecTo = self.pos:vectorTo(obj.pos)
				if vecTo:length() <= self.size + obj.size + math.sqrt(math.abs(obj:getMass())) then
					Color:new(0, 255, 0):set()
					self.speed:normalize():scale(50):DEBUG_draw(self.pos)
					vecTo:DEBUG_draw(self.pos)
				end
			end
		end
	end
end

function Comet:getMass()
	return math.pow(self.size, 2) * math.pi
end

-- --
-- Planet
-- --
Planet = inherit(Object)
Planet.solid = true

function Planet:__init__(pos, size)
	self.pos = pos
	self.size = size
end

function Planet:preupdate(dt)
end

function Planet:update()
end

function Planet:draw()
	Color:new(255, 88, 22):set()
	gfx.drawCircle("fill", self.pos, self.size, 100)
end

function Planet:getMass()
	return math.pow(self.size, 2) * math.pi * 25
end

-- --
-- PointMass
-- --
PointMass = inherit(Planet)
PointMass.solid = false

function PointMass:__init__(pos, mass)
	self.pos = pos
	self.size = 5
	self.mass = mass
end

function PointMass:draw()
	Color:new(0, 0, 0):set()
	gfx.drawCircle("fill", self.pos, self.size)
end

function PointMass:getMass()
	return self.mass
end
