local Types = {}

export type QueryProps = {
	Origin: Vector3,
	Range: number?,
	Resolution: number?,
	Power: number?,
	Bounces: number?,
	IgnoreList: {Instance}?,

	Falloff: "linear" | "exponential" | ((distance: number, max: number, power: number) -> number)?,
	FilterFunction: ((Instance) -> boolean)?,
	PassthroughFunction: ((Instance, Enum.Material?) -> boolean)?,
	OcclusionFunction: ((Instance, Enum.Material?) -> boolean)?,
	DampeningFunction: ((Instance, Enum.Material?) -> number)?,

	-- Optional direction override (mostly unused now)
	Direction: Vector3?,

	-- 🔽 NEW: RayDistribution-specific props 🔽
	Shape: "Point" | "Spherical" | "Surface"?,
	
	--[[ only use if you're using surface ]]--^^^^
	SurfaceNormal: Vector3?,
	SurfaceWidth: number?,
	SurfaceHeight: number?,
}

export type HitData = {
	Position : Vector3,
	Distance : number,
	Instance : Instance,
	Intensity : number,
}

--export type QueryResult = {
--	_Hits : {HitData},
--	_Props : QueryProps,
--	new : (hitData : {HitData}, props : any) -> QueryResult,
--	GetHits : () -> {HitData},
--	GetIntensityAt : (position : Vector3) -> number,
--	DidReach : (position : Vector3) -> boolean,
--	Destroy : () -> (),
--} -- Modified to Typeof(.new()) for the QueryResult for Autocompletion.. Can use if you want for strict

export type RaycasterResult = {
	Position : Vector3,
	Instance : Instance,
	Normal : Vector3,
	MaterialDampening : number,
	Passthrough : boolean,
	Occluded : boolean,
}

return Types
