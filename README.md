# state
A simple, yet versatile state class.

> [!NOTE]
> This is not a full state management library.
> This is only a state class.
---

# Features
- ```state:read() -> T```
- ```state:write(value : T, force : boolean?)```
- ```state:listen(callback : (value : T, old_value : T) -> ()) -> ()```
- ```state:send(value : T)```
- ```state:enabled(enabled : boolean)```
- ```state:is(value : T) -> boolean```
- ```state:isNot(value : T) -> boolean```
