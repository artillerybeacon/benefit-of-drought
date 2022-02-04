// copied from pluto inventory
function DROUGHT.RollChance(crate)
	local m = math.random()

	local total = 0
	for _, v in pairs(crate) do
		total = total + (istable(v) and v.Shares or v)
	end

	m = m * total

	for itemname, val in pairs(crate) do
		if (istable(val)) then
			m = m - val.Shares
		else
			m = m - val
		end

		if (m <= 0) then
			return itemname, val
		end
	end
end