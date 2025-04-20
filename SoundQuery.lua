local Propagator = require("./SoundQuery/Propagator")
local QueryResult = require("./SoundQuery/QueryResult")
local Janitor = require("./SoundQuery/Janitor")
local Types = require("./SoundQuery/Types")

local SoundQuery = {}

type QueryProps = Types.QueryProps

function SoundQuery.Query(props : QueryProps)
	assert(typeof(props.Origin) == "Vector3", "Query must provide an Origin Vector3")
	local hitData = Propagator.Propagate(props)
	local result = QueryResult.new(hitData, props)
	return result
end

return SoundQuery
