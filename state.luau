--!strict

type Struct<T> = {
	read: (self: Struct<T>) -> T,
	write: (self: Struct<T>, new_value: T, force: boolean?) -> (),
	listen: (self: Struct<T>, callback: (value: T, oldValue : T?) -> (), call : boolean?) -> () -> (),
	send: (self: Struct<T>, ...any) -> (),
	enabled: (self: Struct<T>, bool: boolean) -> (),
	is: (self: Struct<T>, query : any) -> boolean,
	isNot: (self : Struct<T>, query : any) -> boolean,
}

type self = {
	value: any?,
	_enabled: boolean,
	_callbacks: {(value: any, oldValue : any) -> ()}
}

local State = {}
State.__index = State

function State.read(self: self)
	return self.value
end

function State.write(self: self, new_value: any?, force: boolean?)
	if not self._enabled then return end

	local callbacks = self._callbacks

	local oldValue = self.value
	if self.value == new_value and not force then
		return
	end

	self.value = new_value

	for i = 1, #callbacks do
		callbacks[i](new_value, oldValue)
	end
end

function State.send(self: self, ...: any)
	if not self._enabled then return end
	local callbacks = self._callbacks
	
	for i = 1, #callbacks do
		callbacks[i](...)
	end
end

function State.listen(self: self, callback: (value: any) -> (), call : boolean?)
	table.insert(self._callbacks, callback)
	
	if call ~= nil and call then
		callback(self.value)
	end
	
	return function()
		local index = table.find(self._callbacks, callback)
		if index == nil then return end
		table.remove(self._callbacks, index)
	end
end

function State.enabled(self: self, bool: boolean)
	self._enabled = bool
end

function State.is(self : self, query : any)
	return self.value == query
end

function State.isNot(self : self, query : any)
	return self.value ~= query
end

return function <T> (value: T): Struct<T>
	return setmetatable({
		value = value,
		_enabled = true,
		_callbacks = {}    
	}, State) :: any
end
