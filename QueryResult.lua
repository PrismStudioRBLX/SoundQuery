local Types = require('./Types')
--type QueryResult = Types.QueryResult -- Optional cause the export down below is being used.
type HitData = Types.HitData
type Props = Types.QueryProps

local QueryResult = {}
QueryResult.__index = QueryResult

function QueryResult.new(hitData : HitData, props : Props)
	local self = setmetatable({}, QueryResult)
	self._Hits = hitData
	self._Props = props
	return self
end

function QueryResult:GetHits() : {HitData}
	return self._Hits
end

function QueryResult:GetIntensityAt(position : Vector3) : number
	local closestIntensity = 0
	for _, hit in ipairs(self._Hits) do
		if (hit.Position - position).Magnitude < 2 then
			closestIntensity = math.max(closestIntensity, hit.Intensity)
		end
	end
	return closestIntensity
end

function QueryResult:DidReach(position : Vector3) : boolean
	return self:GetIntensityAt(position) > 0
end

function QueryResult:Destroy()
	table.clear(self)
	setmetatable(self, nil)
	table.freeze(self)
end

local _a, _b = nil, nil
export type QueryResult = typeof(QueryResult.new(_a, _b))

return QueryResult