
local minute = 60

return {

	Easy = {
		end_at = 0,
		mult = 0
	},
	Medium = {
		end_at = minute * 5,
		mult = 0.2
	},
	Impossible = {
		end_at = 1e9,
		mult = 3
	}

}