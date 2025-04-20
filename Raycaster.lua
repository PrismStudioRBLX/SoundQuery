local Types = require("./Types")
type RaycasterResult = Types.RaycasterResult
type Props = Types.QueryProps

local Raycaster = {}

function Raycaster.CastRay(origin : Vector3, direction : Vector3, props : Props) : RaycasterResult | nil
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = props.IgnoreList or {}
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true

	local result = workspace:Raycast(origin, direction.Unit * (props.Range or 100), params)
	if not result then return nil end
	if props.FilterFunction and not props.FilterFunction(result.Instance) then
		return nil
	end

	local dampening = props.DampeningFunction and props.DampeningFunction(result.Instance, result.Material) or 1
	local passthrough = props.PassthroughFunction and props.PassthroughFunction(result.Instance, result.Material) or false
	local occluded = props.OcclusionFunction and props.OcclusionFunction(result.Instance, result.Material) or false

	return {
		Position = result.Position,
		Instance = result.Instance,
		Normal = result.Normal,
		MaterialDampening = dampening,
		Passthrough = passthrough,
		Occluded = occluded,
	} :: RaycasterResult
end

return Raycaster