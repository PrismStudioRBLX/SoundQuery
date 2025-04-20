local RayDistribution = {}

local function generatePointDirections(origin: Vector3, resolution: number): {{Origin: Vector3, Direction: Vector3}}
	local results = {}
	for i = 1, resolution do
		local angle = (i / resolution) * math.pi * 2
		local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
		table.insert(results, {
			Origin = origin,
			Direction = direction,
		})
	end
	return results
end

local function generateSphericalDirections(origin: Vector3, resolution: number): {{Origin: Vector3, Direction: Vector3}}
	local results = {}
	local goldenRatio = (1 + math.sqrt(5)) / 2
	for i = 0, resolution - 1 do
		local theta = 2 * math.pi * i / goldenRatio
		local phi = math.acos(1 - 2 * (i + 0.5) / resolution)
		local x = math.sin(phi) * math.cos(theta)
		local y = math.sin(phi) * math.sin(theta)
		local z = math.cos(phi)
		local dir = Vector3.new(x, y, z)
		table.insert(results, {
			Origin = origin,
			Direction = dir,
		})
	end
	return results
end

local function generateSurfaceDirections(origin: Vector3, normal: Vector3, width: number, height: number, resolution: number): {{Origin: Vector3, Direction: Vector3}}
	local results = {}
	local up = Vector3.yAxis
	if math.abs(normal:Dot(up)) > 0.95 then
		up = Vector3.xAxis
	end

	local right = normal:Cross(up).Unit
	local surfaceUp = right:Cross(normal).Unit

	local countX = math.floor(math.sqrt(resolution))
	local countY = math.floor(resolution / countX)

	for x = 0, countX - 1 do
		for y = 0, countY - 1 do
			local offsetX = ((x + 0.5) / countX - 0.5) * width
			local offsetY = ((y + 0.5) / countY - 0.5) * height
			local position = origin + right * offsetX + surfaceUp * offsetY
			table.insert(results, {
				Origin = position,
				Direction = normal,
			})
		end
	end

	return results
end

function RayDistribution.Generate(shape: "Point" | "Spherical" | "Surface", resolution: number, props) : {{Origin: Vector3, Direction: Vector3}}
	local origin = props.Origin
	if shape == "Point" then
		return generatePointDirections(origin, resolution)
	elseif shape == "Spherical" then
		return generateSphericalDirections(origin, resolution)
	elseif shape == "Surface" then
		local normal = props.SurfaceNormal or Vector3.zAxis
		local width = props.SurfaceWidth or 2
		local height = props.SurfaceHeight or 2
		return generateSurfaceDirections(origin, normal, width, height, resolution)
	else
		error("Invalid RayDistribution shape: " .. tostring(shape))
	end
end

return RayDistribution