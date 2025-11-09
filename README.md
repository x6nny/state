#⚡ state

A simple, yet versatile **state management class** for Lua / Luau.

This lightweight class provides **reactive, observable values** for dynamic game data, UI binding, and modular scripting — perfect for **Roblox Studio** or any Lua runtime.

> [!NOTE]
> This is **not** a full reactive framework.
> It’s a standalone class that does one thing well — **track and react to state changes**.

---

## 🧠 Overview

The `State` class provides:

* Reactive **value tracking**
* Change **listeners**
* Optional **forced updates**
* Runtime **enable/disable** control
* Lightweight **type utilities**
* Full **typed support** for Luau

---

## 🗂️ Roblox Module Structure

To keep your project organized, you can structure your module like this:

```
ReplicatedStorage
└── Shared
    ├── State
    │   ├── init.lua          -- main State class
    │   └── README.md         -- (optional) documentation
    ├── ExampleUI
    │   └── CounterScript.lua
    └── ExampleServer
        └── CoinSystem.lua
```

**Recommended locations:**

* `ReplicatedStorage.Shared.State` → shared across client & server
* Require it anywhere:

  ```lua
  local State = require(game.ReplicatedStorage.Shared.State)
  ```

---

## ⚙️ API Reference

### `state:read() -> T`

Returns the current value.

### `state:write(value: T, force: boolean?)`

Sets the value and notifies listeners (if changed or forced).

### `state:listen(callback: (newValue: T, oldValue: T) -> ()) -> ()`

Adds a listener. Returns a disconnect function.

### `state:send(value: T)`

Forces listener updates regardless of equality.

### `state:enabled(enabled: boolean)`

Toggles state propagation on/off.

### `state:is(value: T) -> boolean`

Checks if value equals the current state.

### `state:isNot(value: T) -> boolean`

Checks if value differs.

### `state:type() -> string`

Returns the Lua type of the value.

### `state:typeIs(type: string) -> boolean`

Checks if the type matches.

### `state:typeIsNot(type: string) -> boolean`

Checks if the type differs.

---

## 💡 Example Usage (Shared Script)

```lua
local State = require(game.ReplicatedStorage.Shared.State)

local health = State(100)

health:listen(function(new, old)
	print(`Health changed from {old} to {new}`)
end)

health:write(75)
health:write(50)
health:send(50) -- force an update
```

---

## 🧩 Internal Implementation (Typed Luau)

Here’s the typed structure for Roblox Studio (Luau):

```lua
--!strict

type Struct<T> = {
	read: (self: Struct<T>) -> T,
	write: (self: Struct<T>, new_value: T, force: boolean?) -> (),
	listen: (self: Struct<T>, callback: (value: T, oldValue : T?) -> (), call : boolean?) -> () -> (),
	send: (self: Struct<T>, ...any) -> (),
	enabled: (self: Struct<T>, bool: boolean) -> (),
	is: (self: Struct<T>, query : any) -> boolean,
	isNot: (self : Struct<T>, query : any) -> boolean,
	type: (self : Struct<T>) -> string,
	typeIs: (self : Struct<T>, type : string) -> boolean,
	typeIsNot: (self : Struct<T>, type : string) -> boolean,
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

--[=[
	Get the type of the value
	
	@param self : state 
	
	@return string
]=]
function State.type(self : self)
	return typeof(self.value)
end

--[=[
	Check if the state is a certain type
	
	@param self : state 
	@param type : string
	
	@return boolean
]=]
function State.typeIs(self : self, type : string)
	return State.type(self) == type
end

--[=[
	Check if the state is not a certain type
	
	@param self : state 
	@param type : string
	
	@return boolean
]=]
function State.typeIsNot(self : self, type : string)
	return State.type(self) ~= type
end

return function <T> (value: T): Struct<T>
	return setmetatable({
		value = value,
		_enabled = true,
		_callbacks = {}    
	}, State) :: any

end
```

---

## 🎮 Practical Roblox Examples

### 🪄 Example 1: Reactive UI (Client)

Automatically update a `TextLabel` based on state changes.

```lua
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(ReplicatedStorage.Shared.State)

local clicks = State(0)
local label = script.Parent:WaitForChild("ClickCount") :: TextLabel
local button = script.Parent:WaitForChild("ClickButton") :: TextButton

-- Update label text whenever clicks change
clicks:listen(function(new: number)
	label.Text = `Clicks: {new}`
end)

-- Increment on click
button.Activated:Connect(function()
	clicks:write(clicks:read() + 1)
end)
```

---

### 👥 Example 2: Shared Player Data (Server)

```lua
--!strict
local Players = game:GetService("Players")
local State = require(game.ReplicatedStorage.Shared.State)

local playerCoins: { [Player]: any } = {}

Players.PlayerAdded:Connect(function(player)
	local coins = State(0)
	playerCoins[player] = coins

	coins:listen(function(new, old)
		print(player.Name, "coins changed from", old, "to", new)
	end)

	task.spawn(function()
		while player.Parent do
			task.wait(5)
			coins:write(coins:read() + 10)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	playerCoins[player] = nil
end)
```

---

### ⚙️ Example 3: Game Logic State

```lua
--!strict
local State = require(game.ReplicatedStorage.Shared.State)
local phase = State("Waiting")

phase:listen(function(new, old)
	print(`Game phase changed from {old} -> {new}`)
end)

task.wait(5)
phase:write("Playing")
task.wait(10)
phase:write("Ended")
```

---

## 🧱 API Summary

| Method                 | Description                               |
| :--------------------- | :---------------------------------------- |
| `read()`               | Returns the current value                 |
| `write(value, force?)` | Updates the value and notifies listeners  |
| `listen(callback)`     | Subscribes to changes; returns disconnect |
| `send(value)`          | Broadcasts even if unchanged              |
| `enabled(boolean)`     | Enables/disables propagation              |
| `is(value)`            | Checks equality                           |
| `isNot(value)`         | Checks inequality                         |
| `type()`               | Returns Lua type                          |
| `typeIs(type)`         | Checks if type matches                    |
| `typeIsNot(type)`      | Checks if type differs                    |

---

## 🧩 Best Practices

✅ **Place `State` in `ReplicatedStorage.Shared`** for access by both client and server.<br>
✅ **Use one `State` per reactive variable** instead of large data tables.<br>
✅ **Disconnect listeners** when objects (like GUIs or players) are destroyed.<br>
✅ **Combine with `BindableEvents` or Signals** if you need cross-system communication.<br>
✅ **Keep it simple** — `State` is designed to remain lightweight.<br>

---

## 🪶 License

MIT License — free to use, modify, and distribute.
