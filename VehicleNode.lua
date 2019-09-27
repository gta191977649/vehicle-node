--for name, dat in pairs(PathNodes["San Andreas"]) do
--	for i, arr in pairs(dat) do
--		if(arr[5]) then
--			if(arr[5] ~= "west") then
--			
--			elseif(arr[5] ~= "north") then
--			
--			elseif(arr[5] ~= "Bus Stop") then
--			
--			else
--				outputChatBox(name.." "..i.." broken type")
--			end
--		end
--		local zone = getZoneName(arr[2],arr[3],arr[4])
--		if(zone ~= name) then
--			outputChatBox(name.." "..i.." broken zone")
--		end
--			
--		if(arr[6]) then
--			for i2, v in pairs(arr[6]) do
--				if (not PathNodes["San Andreas"][v[1]][v[2]]) then
--				
--					outputChatBox(name.." "..i.." - "..v[1].." "..v[2].." broken path")
--				end
--			end
--		end
--	end
--
--end



function table.copy(t)
	local t2 = {};
	for k,v in pairs(t) do
		if type(v) == "table" then
			t2[k] = table.copy(v);
		else
			t2[k] = v;
		end
	end
	return t2;
end


function NEWGPSFound(city, x,y,z, x2,y2,z2)
	local startzone = exports["ps2_weather"]:GetZoneName(x,y,z, false, city)
	local endzone = exports["ps2_weather"]:GetZoneName(x2,y2,z2, false, city)
	if(not PathNodes[city]) then return false end
	
	if(PathNodes[city][startzone] and PathNodes[city][endzone]) then
		local tmp = {
			["startdist"] = {[1] = 9999, [2] = 9999, [3] = 9999, [4] = 9999}, 
			["enddist"] = {[1] = 9999, [2] = 9999, [3] = 9999, [4] = 9999}, 
			["tmpdist"] = 9999, 
			["startnode"] = {},
			["endnode"] = {},
			["nextnodes"] = {}, 
			["threads"] = {}, 
			["usablepaths"] = {[startzone] = {}}
		}
		for count = 1, 4 do
			for i,k in pairs(PathNodes[city][startzone]) do
				local double = false
				for _, b in pairs(tmp["startnode"]) do
					if(b == i) then
						double = true 
					end
				end
				if(not double) then
					tmp["tmpdist"] = getDistanceBetweenPoints2D(x, y, k[2], k[3])
					if(tmp["tmpdist"] < tmp["startdist"][count]) then
						tmp["startdist"][count] = tmp["tmpdist"]
						tmp["startnode"][count] = i
					end
				end
			end
		end
		
		for count = 1, 4 do
			for i,k in pairs(PathNodes[city][endzone]) do
				local double = false
				for _, b in pairs(tmp["endnode"]) do
					if(b == i) then
						double = true 
					end
				end
				if(not double) then
					tmp["tmpdist"] = getDistanceBetweenPoints2D(x2, y2, k[2], k[3])
					if(tmp["tmpdist"] < tmp["enddist"][count]) then
						tmp["enddist"][count] = tmp["tmpdist"]
						tmp["endnode"][count] = i
					end
				end
			end
		end
		
		for i, v in pairs(tmp["startnode"]) do
			tmp["nextnodes"][i] = {startzone, v, i, {[1] = i}}
			tmp["threads"][i] = {}
		end
		
		for is = 1, 50000 do
			for i, arr in pairs(tmp["nextnodes"]) do
				if(not tmp["usablepaths"][arr[1]]) then 
					tmp["usablepaths"][arr[1]] = {}
				end
				
				if(tmp["usablepaths"][arr[1]][arr[2]]) then -- Если попали в петлю
				--	tmp["threads"][arr[3]] = nil
					tmp["nextnodes"][i] = nil
				else
					tmp["usablepaths"][arr[1]][arr[2]] = true
					
					if(PathNodes[city][arr[1]][arr[2]][6]) then
						if(PathNodes[city][arr[1]][arr[2]+1]) then
							table.insert(tmp["threads"], {{arr[1], arr[2]}})
							local newarr = table.copy(arr[4])
							table.insert(newarr, #tmp["threads"])
							table.insert(tmp["nextnodes"], {arr[1], arr[2]+1, #tmp["threads"], newarr})
						end
						
						for i2, k2 in pairs(PathNodes[city][arr[1]][arr[2]][6]) do
							table.insert(tmp["threads"], {{arr[1], arr[2]}})
							local newarr = table.copy(arr[4])
							table.insert(newarr, #tmp["threads"])
							table.insert(tmp["nextnodes"], {k2[1], k2[2], #tmp["threads"], newarr})
						end
					else
						table.insert(tmp["threads"][arr[3]], {arr[1], arr[2]})
						tmp["nextnodes"][i] = {arr[1], arr[2]+1, arr[3], arr[4]}
					end
					
					
					
					for _, node in pairs(tmp["endnode"]) do
						if(arr[1] == endzone and arr[2] == node) then
							local out = {}
							for _, id in pairs(arr[4]) do
								for _, el in pairs(tmp["threads"][id]) do
									table.insert(out, el)
								end
							end
							--outputChatBox("Готово! "..arr[1].." "..arr[2].." Размер пути: "
							--..#out.." Всего потоков: "..#tmp["threads"].." Количество потоков:"..#arr[4])
							return out
						end
					end
				end
			end
		end
	end
	return false
end


function GetVehicleNodes()
	return PathNodes
end
		


function GetCoordsByGPS(city, arr)
	local out = {}
	for _, v in pairs(arr) do
		out[#out+1] = {PathNodes[city][v[1]][v[2]][2], PathNodes[city][v[1]][v[2]][3], PathNodes[city][v[1]][v[2]][4]}
	end	
	return out
end
		


function GetPathByCoordsNEW(thePlayer, gx,gy,gz,gx2,gy2,gz2)
	local City = getPlayerCity(thePlayer)
	local arr = NEWGPSFound(City, gx,gy,gz,gx2,gy2,gz2)
	
	if(arr) then
		triggerClientEvent(thePlayer, "SetGPS", thePlayer, toJSON(GetCoordsByGPS(City, arr)))
		return true
	else
		triggerClientEvent(thePlayer, "ToolTip", thePlayer, "GPS: Невозможно найти путь!")
	end
	return false
end
addEvent("GetPathByCoordsNEW", true)
addEventHandler("GetPathByCoordsNEW", root, GetPathByCoordsNEW)


function FindBusStop(thePlayer, city)
	local x,y,z = getElementPosition(thePlayer)
	local startzone = exports["ps2_weather"]:GetZoneName(x,y,z, false, city)
	
	if(PathNodes[city][startzone]) then
		local tmp = {
			["startdist"] = {[1] = 9999, [2] = 9999, [3] = 9999, [4] = 9999}, 
			["enddist"] = {[1] = 9999, [2] = 9999, [3] = 9999, [4] = 9999}, 
			["tmpdist"] = 9999, 
			["startnode"] = {},
			["endnode"] = {},
			["nextnodes"] = {}, 
			["threads"] = {}, 
			["usablepaths"] = {[startzone] = {}}
		}
		for count = 1, 4 do -- Находим 4 ближние ноды
			for i,k in pairs(PathNodes[city][startzone]) do
				local double = false
				for _, b in pairs(tmp["startnode"]) do
					if(b == i) then
						double = true 
					end
				end
				if(not double) then
					tmp["tmpdist"] = getDistanceBetweenPoints2D(x, y, k[2], k[3])
					if(tmp["tmpdist"] < tmp["startdist"][count]) then
						tmp["startdist"][count] = tmp["tmpdist"]
						tmp["startnode"][count] = i
					end
				end
			end
		end
		
		for i, v in pairs(tmp["startnode"]) do
			tmp["nextnodes"][i] = {startzone, v, i, {[1] = i}}
			tmp["threads"][i] = {}
		end
		
		
		
		for is = 1, 10000 do
			for i, arr in pairs(tmp["nextnodes"]) do
				if(not tmp["usablepaths"][arr[1]]) then 
					tmp["usablepaths"][arr[1]] = {}
				end
				
				if(tmp["usablepaths"][arr[1]][arr[2]]) then -- Если попали в петлю
				--	tmp["threads"][arr[3]] = nil
					tmp["nextnodes"][i] = nil
				else
					tmp["usablepaths"][arr[1]][arr[2]] = true
					
					if(PathNodes[city][arr[1]][arr[2]][6]) then
						if(PathNodes[city][arr[1]][arr[2]+1]) then
							table.insert(tmp["threads"], {{arr[1], arr[2]}})
							local newarr = table.copy(arr[4])
							table.insert(newarr, #tmp["threads"])
							table.insert(tmp["nextnodes"], {arr[1], arr[2]+1, #tmp["threads"], newarr})
						end
						
						for i2, k2 in pairs(PathNodes[city][arr[1]][arr[2]][6]) do
							table.insert(tmp["threads"], {{arr[1], arr[2]}})
							local newarr = table.copy(arr[4])
							table.insert(newarr, #tmp["threads"])
							table.insert(tmp["nextnodes"], {k2[1], k2[2], #tmp["threads"], newarr})
						end
					else
						table.insert(tmp["threads"][arr[3]], {arr[1], arr[2]})
						tmp["nextnodes"][i] = {arr[1], arr[2]+1, arr[3], arr[4]}
					end
					
					
					if(PathNodes[city][arr[1]][arr[2]][5]) then
						if(PathNodes[city][arr[1]][arr[2]][5] == "Bus Stop") then
							local out = {}
							for _, id in pairs(arr[4]) do
								for _, el in pairs(tmp["threads"][id]) do
									table.insert(out, el)
								end
							end
							if(#out > 1) then -- Если размер пути больше 1
								--outputChatBox("Готово! "..arr[1].." "..arr[2].." Размер пути: "
								--..#out.." Всего потоков: "..#tmp["threads"].." Количество потоков:"..#arr[4])
								
								triggerClientEvent(thePlayer, "SetGPS", thePlayer, toJSON(GetCoordsByGPS(city, out)))
								return true
							end
						end
					end
				end
			end
		end
	end
		
end
addEvent("FindBusStop", true)
addEventHandler("FindBusStop", root, FindBusStop)



function getPlayerCity(thePlayer)
	return getElementData(thePlayer, "City") or "San Andreas"
end



