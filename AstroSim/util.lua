-- --
-- Requires
-- --
require "class"

require "math"

-- --
-- Color
-- --
Color = inherit(Object)

function Color:__init__(r, g, b)
	self.r = r
	self.g = g
	self.b = b
end

function Color:set()
	love.graphics.setColor(self.r, self.g, self.b)
end

-- --
-- Utility iterators
-- --
function list_iter(t)
	local i = 0
	local len = table.getn(t)
	return function()
		i = i + 1
		if i <= len then return t[i] end
	end
end

-- --
-- Vector2f
-- --
Vector2f = inherit(Object)

function Vector2f:fromAngle(angle, length)
	return Vector2f:new(math.cos(angle) * length, math.sin(angle) * length)
end

function Vector2f:__init__(x, y)
	self.x = x
	self.y = y
end

function Vector2f:__add__(tg)
	return Vector2f:new(self.x + tg.x, self.y + tg.y)
end

function Vector2f:__sub__(tg)
	return Vector2f:new(self.x - tg.x, self.y - tg.y)
end

function Vector2f:__mul__(scalar)
	return Vector2f:new(self.x * scalar, self.y * scalar)
end

function Vector2f:vectorTo(tg)
	return tg - self
end

Vector2f.scale = Vector2f.__mul__

function Vector2f:copy()
	return Vector2f:new(self.x, self.y)
end

function Vector2f:normalize()
	local length = self:length()
	return Vector2f:new(self.x / length, self.y / length)
end

function Vector2f:length()
	return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2))
end

function Vector2f:mirrorXY()
	return Vector2f:new(-self.x, -self.y)
end

function Vector2f:mirrorX()
	return Vector2f:new(-self.x, self.y)
end

function Vector2f:mirrorY()
	return Vector2f:new(self.x, -self.y)
end

function Vector2f:swapXY()
	return Vector2f:new(self.y, self.x)
end

function Vector2f:dot(tg)
	return self.x * tg.x + self.y * tg.y
end

function Vector2f:angleBetween(tg)
	return math.acos( self:dot(tg) / (self:length() * tg:length()) )
end

function Vector2f:projectedOn(tg)
	return tg:normalize():scale(math.cos(self:angleBetween(tg)) * self:length())
end

function Vector2f:mirrorAround(tg)
	return self:projectedOn(tg):scale(2) - self
end

function Vector2f:rotate(angle)
	return Vector2f:new(
		self.x * math.cos(angle) - self.y * math.sin(angle),
		self.x * math.sin(angle) + self.y * math.cos(angle)
	)
end

function Vector2f:DEBUG_draw(origin)
	gfx.drawLine(origin, origin + self)
	gfx.drawCircle("fill", origin + self, 2)
end

function Vector2f:__eq__(tg)
	return self.x == tg.x and self.y == tg.y
end

Vector2f.null = Vector2f:new(0, 0)
Vector2f.right = Vector2f:new(1, 0)
Vector2f.left = Vector2f:new(-1, 0)
Vector2f.down = Vector2f:new(0, 1)
Vector2f.up = Vector2f:new(0, -1)

-- --
-- List
-- --
List = inherit(Object)

function List:__init__(...)
	self.arr = ... or {}
end

function List:at(idx)
	return self.arr[idx]
end

function List:remove(itm)
	for i, item in ipairs(self.arr) do
		if item == itm then
			table.remove(self.arr, i)
			break
		end
	end
end

function List:removeAll(item)
	for i, item in ipairs(self.arr) do
		if item == itm then
			table.remove(self.arr, i)
		end
	end
end

function List:length()
	return #self.arr
end

function List:insert(idx, item)
	table.insert(self.arr, idx, item)
end

function List:pop(idx)
	table.remove(self.arr, idx)
end

function List:popStart()
	self:pop(1)
end

function List:popEnd()
	self:pop(self:length() - 1)
end

function List:push(item)
	self:insert(self:length() + 1, item)
end

function List:iter()
	local idx = 0
	return function()
		idx = idx + 1
		if idx > #self.arr then return nil end
		return self.arr[idx]
	end
end

function List:forEach(f)
	for e in self:iter() do
		f(e)
	end
end

function List:lua_arr()
	local arr = {}
	for k, v in pairs(self.arr) do arr[k] = v end
	return arr
end

-- --
-- Graphics
-- --
gfx = {
	drawCircle = function(mode, pos, rad, seg)
		love.graphics.circle(mode, pos.x, pos.y, rad, seg)
	end,
	drawLine = function(pos, tg)
		love.graphics.line(pos.x, pos.y, tg.x, tg.y)
	end,
}

-- --
-- Cursor
-- --
cursor = {
	getPosition = function()
		return Vector2f:new(love.mouse.getX(), love.mouse.getY())
	end,
}

-- --
-- HSL
-- --
-- Converts HSL to RGB. (input and output range: 0 - 255)
function HSL(h, s, l)
    if s <= 0 then return l,l,l end
    h, s, l = h/256*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m)*255,(g+m)*255,(b+m)*255
end

-- --
-- Dump
-- --
function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k, v in pairs(o) do
			if type(k) ~= 'number' then k = '"' .. k .. '"' end
			s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end
