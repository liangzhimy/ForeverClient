Queue = {
	first = nil,
	last = nil,
	count = nil,
	values = nil,
	index = nil,
	create = function(self)
		self.values = new({})
		self.first = 1
		self.last = 0
		self.count = 0
		self.index = new({})
		return self
	end,
	push = function(self,value)
		if self.first==1 and self.last==0 then
			self:pushFront(value)
		else
			self:pushBack(value)
		end
	end,
	pushFront = function(self,value)
		local first = self.first - 1;
		self.first = first
		self.values[first] = value
		self.count = self.count + 1
	end,
	pushBack = function(self,value)
		local last = self.last + 1
		self.last = last
		self.values[last] = value
		self.count = self.count + 1
	end,
	popFirst = function(self)
		local first = self.first
		if first > self.last then
			return
		end
		local value = self.values[first]
		self.values[first] = nil
		self.first = first + 1
		self.count = self.count - 1
		return value
	end,
	popLast = function(self)
		local last = self.last
		if self.first > last then
			return
		end
		local value = self.values[last]
		self.values[last] = nil
		self.last = last - 1
		self.count = self.count - 1
		return value
	end,

	CountValue = function(self)
		return self.count
	end,

	empty = function(self)
		local last = self.last
		if self.first > last then
			return true
		else
			return false
		end
	end,
	
	isHave = function(self,v) ---values必须是从后面插入
		local last = self.last
		if self.first > last then
			return
		end
		local c = 0

		for i = 1,table.getn(self.values) do
			if self.values[i] == v then
				c = c + 1
			end
		end

		if c > 0 then
			return true
		else
			return false
		end
	end,
	destroyData = function(self)
		self.values = nil
		self.index = nil
		self.first = 1
		self.last = 0
		self.count = 0
	end,
}

