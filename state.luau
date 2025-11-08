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


--[=[
	Get the current state.
	
	@param self : state
	
	@return T
]=]
function State.read(self: self)
	return self.value
end

--[=[
	Set the state to a new state
	
	@param self : state 
	@param new_value : T
	@param force : boolean
]=]
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

--[=[
	Send a value to all the callbacks without changing state
	
	@param self : state 
	@param ... : any
]=]
function State.send(self: self, ...: any)
	if not self._enabled then return end
	local callbacks = self._callbacks
	
	for i = 1, #callbacks do
		callbacks[i](...)
	end
end

--[=[
	Listen to when the state changes and for any sent values
	
	@param self : state 
	@param callback : ( value : any )
	@param call : boolean ?
	
	@return () -> ()
]=]
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

--[=[
	Enable or disable the state
	
	@param self : state 
	@param bool : boolean
]=]
function State.enabled(self: self, bool: boolean)
	self._enabled = bool
end

--[=[
	Check if the state is a value
	
	@param self : state 
	@param query : any
	
	@return boolean
]=]
function State.is(self : self, query : any)
	return self.value == query
end

--[=[
	Check if the state is not a value
	
	@param self : state 
	@param query : any
	
	@return boolean
]=]
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
