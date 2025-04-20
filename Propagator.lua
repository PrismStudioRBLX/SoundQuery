--[[
Ray Visualization Key:

🔴 Red    Occluded ray (blocked completely)
🟢 Green  Valid hit (surface bounced or stopped)
🟡 Yellow Passthrough (partially passed through)
]]

local Raycaster = require("./Raycaster")
local RayDistribution = require("./RayDistribution")
local Types = require("./Types")
type HitData = Types.HitData
type QueryProps = Types.QueryProps

local Propagator = {}
Propagator.DespawnTime = 20
Propagator.Debug = true

local debugParts = {}

local function visualizeRay(startPos, endPos, color): ()
	if not Propagator.Debug then return end
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(0.1, 0.1, (endPos - startPos).Magnitude)
	part.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -part.Size.Z / 2)
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Transparency = 0.3
	part.Name = "SoundRay"
	part.Parent = workspace
	game:GetService("Debris"):AddItem(part, Propagator.DespawnTime)
	table.insert(debugParts, part)
end

local function getIgnoredParts()
	return debugParts
end

local function defaultFalloff(distance, maxDistance, power): number
	local ratio = distance / maxDistance
	return power * (1 - ratio)
end

function Propagator.SetDespawnTime(timeToSet: number)
	assert(typeof(timeToSet) == 'number', 'Time given to Propagator Despawn Time function is NOT a number.')
	Propagator.DespawnTime = timeToSet
end

local function GenerateSphericalDirections(n): {Vector3}
	local dirs = {}
	local goldenRatio = (1 + math.sqrt(5)) / 2

	for i = 0, n - 1 do
		local theta = 2 * math.pi * i / goldenRatio
		local phi = math.acos(1 - 2 * (i + 0.5) / n)

		local x = math.sin(phi) * math.cos(theta)
		local y = math.sin(phi) * math.sin(theta)
		local z = math.cos(phi)

		table.insert(dirs, Vector3.new(x, y, z))
	end

	return dirs
end

function Propagator.Propagate(props : QueryProps): {HitData}
	local shape = props.Shape or "Point"
	local resolution = props.Resolution or 32
	local origin = props.Origin
	local range = props.Range or 100
	local bounces = props.Bounces or 1
	local power = props.Power or 1
	local ignore = props.IgnoreList or {}
	local falloff = props.Falloff or defaultFalloff

	if type(falloff) == "string" then
		if falloff == "linear" then
			falloff = function(d, max, p)
				return p * (1 - (d / max))
			end
		elseif falloff == "exponential" then
			falloff = function(d, max, p)
				return p * math.exp(-d / max)
			end
		end
	end

	local hits = {}

	local rayDirections = RayDistribution.Generate(shape, resolution, props)

	for _, rayInfo in rayDirections do
		local currentOrigin = rayInfo.Origin
		local dir = rayInfo.Direction
		local remainingPower = power
		local depth = 0

		while depth <= bounces and remainingPower > 0.01 do
			local result = Raycaster.CastRay(currentOrigin, dir, {
				Origin = origin,
				Range = range,
				IgnoreList = ignore,
				FilterFunction = props.FilterFunction,
				PassthroughFunction = props.PassthroughFunction,
				OcclusionFunction = props.OcclusionFunction,
				DampeningFunction = props.DampeningFunction,
			})

			if result then
				local hitPos = result.Position
				local distance = (hitPos - currentOrigin).Magnitude
				local materialDamp = result.MaterialDampening or 1
				local passthrough = result.Passthrough or false
				local occluded = result.Occluded or false

				if occluded then
					visualizeRay(currentOrigin, hitPos, Color3.fromRGB(255, 0, 0))
					break
				end

				local intensity = falloff(distance, range, remainingPower) * materialDamp

				table.insert(hits, {
					Position = hitPos,
					Distance = distance,
					Instance = result.Instance,
					Intensity = intensity,
				})

				visualizeRay(currentOrigin, hitPos, passthrough and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(0, 255, 0))

				if not passthrough and result.Normal then
					dir = dir - 2 * dir:Dot(result.Normal) * result.Normal
				end

				currentOrigin = hitPos + dir * 0.1
				remainingPower *= passthrough and (0.8 * materialDamp) or (0.5 * materialDamp)
				depth += 1

				local currentDebugParts = getIgnoredParts()
				for _, part in pairs(currentDebugParts) do
					if part:IsA('BasePart') then
						table.insert(ignore, part)
					end
				end
			else
				break
			end
		end
	end

	return hits
end


return Propagator
