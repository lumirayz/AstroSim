Object = {}

function Object:new(...)
	local o = {}
	setmetatable(o, {
		-- Lookup
		__index = self,
		__newindex = nil,
		
		-- Arithmetic
		__add = self.__add__,
		__sub = self.__sub__,
		__mul = self.__mul__,
		__div = self.__div__,
		__unm = self.__neg__,
		__pow = self.__pow__,
		
		-- Relational
		__eq = self.__eq__,
		__lt = self.__lt__,
		__le = self.__le__,
		__gt = self.__gt__,
		__ge = self.__ge__,
	})
	o.class = self
	o:__init__(...)
	return o
end

function Object:__init__(...) end

function Object:__add__(tg) end
function Object:__sub__(tg) end
function Object:__mul__(tg) end
function Object:__div__(tg) end
function Object:__neg__() end
function Object:__pow__(tg) end

function Object:__eq__(tg) return false end
function Object:__lt__(tg) return false end
function Object:__le__(tg) return false end
function Object:__gt__(tg) return false end
function Object:__ge__(tg) return false end

function inherit(class)
	local o = {}
	setmetatable(o, {__index = class})
	return o
end

function super(class)
	return getmetatable(class).__index
end
