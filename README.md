# state

A simple, yet versatile **state management class** for Lua.

This utility provides a lightweight abstraction over value storage and change propagation.
It’s designed for developers who want to maintain and react to dynamic state changes without the complexity of a full state management library.

> [!NOTE]
> This is **not** a complete state management framework — it’s a simple, self-contained class meant for lightweight applications and modular scripts.

---

## 🧠 Overview

The `state` class provides a simple interface for:

* Reading and writing reactive values
* Listening for changes
* Broadcasting new values
* Enabling/disabling updates

It’s ideal for cases where you need **reactivity** or **data binding** without external dependencies or heavy frameworks.

---

## ⚙️ API Reference

### `state:read() -> T`

Returns the current value stored in the state.

```lua
local count = state:read()
print(count)  --> e.g. 5
```

---

### `state:write(value : T, force : boolean?)`

Sets a new value for the state.
If the new value differs from the old one, all listeners are notified.
If `force` is `true`, listeners are notified even if the value didn’t change.

```lua
state:write(10)
state:write(10, true) -- forces update callbacks
```

---

### `state:listen(callback : (value : T, old_value : T) -> ()) -> ()`

Registers a listener function that triggers whenever the state changes.
Returns a disconnect function to stop listening.

```lua
local disconnect = state:listen(function(new, old)
	print("State changed from", old, "to", new)
end)

state:write(42)
-- Output: State changed from <old> to 42

disconnect() -- stop listening
```

---

### `state:send(value : T)`

Alias for `state:write(value, true)` — always triggers listeners, even if the value is the same.

Useful for forcing downstream updates or refreshes.

```lua
state:send(state:read())
```

---

### `state:enabled(enabled : boolean)`

Enables or disables state updates and notifications.

* When disabled, `write` and `send` calls are ignored.
* When re-enabled, state resumes normal behavior.

```lua
state:enabled(false)
state:write(50) -- ignored

state:enabled(true)
state:write(60) -- now works again
```

---

### `state:is(value : T) -> boolean`

Checks if the current state equals the provided value.

```lua
if state:is(10) then
	print("Value is 10")
end
```

---

### `state:isNot(value : T) -> boolean`

The inverse of `state:is(value)`.

```lua
if state:isNot(10) then
	print("Value is not 10")
end
```

---

## 💡 Example Usage

```lua
local State = require(script.state)

local counter = State.new(0)

counter:listen(function(new, old)
	print("Counter changed from", old, "to", new)
end)

counter:write(1)
counter:write(2)
counter:send(2) -- forces re-trigger even though value is same
```

**Output:**

```
Counter changed from 0 to 1
Counter changed from 1 to 2
Counter changed from 2 to 2
```

---

## 🧩 Implementation Notes

* Each `state` instance holds:

  * The current value
  * A list of listeners
  * An enabled/disabled flag
* Listeners are only called when `enabled == true`
* Equality checks use Lua’s native `==` operator
* Safe for use across multiple scripts (no global side effects)

---

## 🧱 Example Use Cases

* Reactive UI updates (e.g., updating text labels)
* Internal state tracking for modules
* Shared state between systems (e.g., player data, score, game mode)
* Lightweight signaling between scripts

---

## 🧰 API Summary

| Method                 | Description                                           |
| :--------------------- | :---------------------------------------------------- |
| `read()`               | Returns the current value                             |
| `write(value, force?)` | Updates the value and notifies listeners              |
| `listen(callback)`     | Attaches a listener and returns a disconnect function |
| `send(value)`          | Broadcasts value to listeners regardless of change    |
| `enabled(boolean)`     | Enables/disables updates                              |
| `is(value)`            | Checks if the value equals the given one              |
| `isNot(value)`         | Checks if the value does not equal the given one      |

---

## 🪶 License

MIT License — free to use and modify.
