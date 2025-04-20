# 🔊 SoundQuery

**SoundQuery** is a modular sound propagation system for Roblox. It simulates how sound travels through 3D space using raycasting, supporting falloff models, reflection bounces, occlusion, passthrough behavior, and dampening. It’s useful for AI hearing, acoustic simulations, or stealth game mechanics.

---

## 📦 Module Structure

| Module               | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `SoundQuery.lua`     | Main interface for running a sound query. Returns a `QueryResult` object.   |
| `Types.lua`          | Type definitions used across modules (`QueryProps`, `HitData`, etc).        |
| `Propagator.lua`     | Core engine for casting rays and simulating bounce & intensity falloff.     |
| `Raycaster.lua`      | Performs raycasts with dampening, occlusion, and passthrough logic.         |
| `QueryResult.lua`    | A query result wrapper that allows further analysis of hits & intensity.     |

---

## 🔁 Flow Overview

1. `SoundQuery.Query(props)` is called with a set of query parameters.
2. `Propagator.Propagate(props)` casts rays based on resolution, direction, and bounces.
3. `Raycaster.CastRay(...)` interprets collisions with environmental data (e.g., materials).
4. The result is returned via `QueryResult.new(...)` for inspection by the caller.

---

## 🧠 Features

- 🔁 Directional or omnidirectional propagation  
- 🔨 Customizable falloff (`linear`, `exponential`, or a custom function)  
- 💥 Optional multi-bounce support (reflections)  
- 🚪 Passthrough and occlusion logic per material or instance  
- 🎚️ Dampening per material  
- 🧽 Clean-up supported (manual or via Janitor integration — WIP)  

---

## 📥 Basic Example

```lua
local SoundQuery = require(path.to.SoundQuery)

local result = SoundQuery.Query({
    Origin = Vector3.new(0, 10, 0),
    Range = 50,
    Resolution = 64,
    Power = 1,
    Bounces = 2,
    Falloff = "exponential",
})

if result:DidReach(Vector3.new(15, 10, 0)) then
    print("Sound reached the listener!")
end

result:Destroy()
