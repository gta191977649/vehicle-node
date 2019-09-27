local screenWidth, screenHeight = guiGetScreenSize()
local scale = (screenWidth/1920)+(screenHeight/1080)
local NewScale = ((screenWidth/1920)+(screenHeight/1080))/2
local GroundMaterial = {}
local VideoMemory = {["HUD"] = {}}
local RailRoadsSA = exports["vehicle_node"]:GetRailnodes()

local trafficlight = {
	["0"] = "west",
	["1"] = "west",
	["2"] = false,
	["3"] = "north",
	["4"] = "north"
}
local PData = {
	["changezone"] = {} -- Для разработчика
}





-- Object, Model, Scale, x,y,z,rz, bizname
local ResourceInMap = {
	--[1] = {false, 17005, 0.1, -382, -1437, 26,0, "FARMFR"},
	--[2] = {false, 3375, 0.1, 1918, 173, 36, 0, "FARMPK"},
	--[3] = {false, 12915, 0.1, -44.4, 78.7, 3.1, 0, "FARMBA"},
	--[4] = {false, 17335, 0.1, -1439, -1534, 101, 90, "FARMWS"}, 
	--[5] = {false, 10357, 0.05, -2523, -622, 132, 0, "ELSF"}, 
	--
	----[7] = {false, 8079, 0.02, 1573, 1791, 9.8, 0, "MEDLV"}, 
	----[8] = {false, 3976, 0.02, 1555.2, -1675.6, 16.2, 0, "PLSPD"},
	----[9] = {false, 5708, 0.02, 1140, -1342, 15.4, 0, "MEDLS"}, 
	--
	--[10] = {false, 12988, 0.07, 1362, 328, 20.5, 335, "BIOEN"}, 
	--[11] = {false, 3426, 0.1, 187, 1415, 10.6, 335, "PETLV"}, 
	--[12] = {false, 17017, 0.05, -1040, -644, 132, 335, false}, 
	--[13] = {false, 17021, 0.05, -1040, -644, 32, 335, "NPZSF"}, 
	--[14] = {false, 7493, 0.02, 966.9, 2140.8, 10.8, 0, "MEATFA"}, 
	--[15] = {false, 10775, 0.02, -1858, 3, 15.1, 0, "SOLIN"}, 
	--[16] = {false, 12931, 0.02, -70, -270, 5.4, 90, "FLEIS"},  
	--[17] = {false, 16399, 0.02, -300.5, 2658.7, 63, 0, "LASPA"}, 
	--[18] = {false, 18474, 0.02, -2192.1, -2432.9, 31, 0, "ANLPI"}, 
	--[19] = {false, 11456, 0.02, -1520.5, 2573.9, 55.8, 0, "ELQUE"}, 
	--[20] = {false, 11436, 0.02, -818.2, 1560.6, 27.1, 0, "LASBA"}, 
	--[21] = {false, 16385, 0.02, -135.1, 1116.8, 20.2, 0, "FORCA"}, 
	--[22] = {false, 9243, 0.02, -2455.7, 2293, 5, 0, "BAYSA"}, 
	--[23] = {false, 5131, 0.02, 2179.5, -2256.2, 14.8, 0, "LOSSA"}, 
	--[24] = {false, 12863, 0.02, 710.9, -569.4, 16.3, 0, "DILLI"}, 
	--[25] = {false, 13066, 0.02, 169.1, -34.3, 1.6, 0, "BLUEB"}, 
	--[26] = {false, 8060, 0.02, 1708.6, 1073.7, 10.8, 0, "LASVE"}, 
	--[27] = {false, 13078, 0.02, 1228.1, 182.7, 20.3, 0, "MONTG"}, 
	--[28] = {false, 12964, 0.02, 2246.4, 52.4, 26.7, 0, "PALOM"}, 
	--[29] = {false, 11092, 0.02, -2119.9, -26.1, 35.3, 0, "SANFI"}, 
	--[30] = {false, 3755, 0.02, 2483.8, -2115.9, 13.5, 0, "FOSOI"}, 
}





function map()
	PData["ResourceMap"] = {[1] = {}, [2] = {}, [3] = {}} -- 1 Roads, 2 Railroads, 3 GPS
	
	for zone, arr in pairs(PathNodes[getPlayerCity(localPlayer)]) do
		for i, arr2 in pairs(arr) do
			local nextmarkers = {}
			if(arr2[6]) then
				for _,k in pairs(arr2[6]) do
					table.insert(nextmarkers, {k[1], k[2]})
				end
			end
			
			if(PathNodes[getPlayerCity(localPlayer)][zone][i+1]) then
				table.insert(nextmarkers, {zone, i+1})
			end
			
			for _, arr3 in pairs(nextmarkers) do
				local dat = PathNodes[getPlayerCity(localPlayer)][arr3[1]][arr3[2]]
				local color = tocolor(60,60,60,255)
				if(getPlayerCity(localPlayer) == "Vice City") then
					color = tocolor(0,0,0,255)
				end
				if(dat[1] == "Closed" or arr2[1] == "Closed") then
					color = tocolor(90,90,90,255)
				end
				
				x,y,z = GetCoordOnMap(arr2[2], arr2[3], arr2[4])
				x2,y2,z2 = GetCoordOnMap(dat[2], dat[3], dat[4])
				PData["ResourceMap"][1][#PData["ResourceMap"][1]+1] = {x,y,z,x2,y2,z2, color, 10}
				
				if(dat[5]) then
					if(dat[5] == "Bus Stop") then
						table.insert(ResourceInMap, {false, 1257, 0.1, arr2[2], arr2[3], arr2[4],findRotation(arr2[2], arr2[3],dat[2], dat[3]), "BUS STOP"})
					end
				end
			end
		end
	end
	
	for i, dat in pairs(ResourceInMap) do
		if(not dat[1]) then
			mx,my,mz = GetCoordOnMap(dat[4],dat[5],dat[6])
			dat[1] = createObject(dat[2], mx,my,mz+0.1, 0,0,dat[7], true) -- Чуть завышены так как толщина линий 1
			setObjectScale(dat[1], dat[3])
			if(dat[8]) then
				local col = createColSphere(mx,my,mz, 2)
				attachElements(col, dat[1])
				setElementData(dat[1], "NameInMap", dat[8])
			end

		end
	end
	
	UpdateGPSMap()
	
	if(getPlayerCity(localPlayer) == "San Andreas") then
		for zone, arr in pairs(RailRoadsSA) do
			for i, arr2 in pairs(arr) do
				
				local nextmarkers = {}
				if(arr2[6]) then
					for _,k in pairs(arr2[6]) do
						table.insert(nextmarkers, {k[1], k[2]})
					end
				end
				
				if(RailRoadsSA[zone][i+1]) then
					table.insert(nextmarkers, {zone, i+1})
				end
				
				for _, arr3 in pairs(nextmarkers) do
					if(RailRoadsSA[arr3[1]]) then
						local dat = RailRoadsSA[arr3[1]][arr3[2]]
						if(dat) then
							x,y,z = GetCoordOnMap(arr2[2], arr2[3], arr2[4])
							x2,y2,z2 = GetCoordOnMap(dat[2], dat[3], dat[4])
							PData["ResourceMap"][2][#PData["ResourceMap"][2]+1] = {x,y,z,x2,y2,z2, tocolor(99,0,0,255), 10}
						end
					end
				end
			end
		end
	end
	
	setCameraMatrix(0, 0, 4250, 0, 0, 4000, 0, 70)
	
	setFarClipDistance(600)
	setWeather(0)--nen
	showCursor(true)
end
addEvent("map", true)
addEventHandler("map", localPlayer, map)


function GetCoordOnMap(x,y,z)
	return x/50,y/50,z/50+(4000)
end


function UpdateGPSMap()
	if(PData["gps"]) then
		PData["ResourceMap"][3] = {}
		local oldmarker = false
		for i,v in pairs(PData["gps"]) do
			if(oldmarker) then
				local x,y,z = unpack(fromJSON(getElementData(v, "coord")))
				local x2,y2,z2 = unpack(fromJSON(getElementData(oldmarker, "coord")))
				x,y,z = GetCoordOnMap(x,y,z)
				x2,y2,z2 = GetCoordOnMap(x2,y2,z2)
				PData["ResourceMap"][3][#PData["ResourceMap"][3]+1] = {x,y,z,x2,y2,z2, tocolor(255,0,0,255), 10}
			end
			oldmarker = v
		end
	end
end


function SetGPS(arr)
	if(PData["gps"]) then
		for i, el in pairs(PData["gps"]) do
			destroyElement(el)
		end
	end
	PData["gps"] = {}
	arr = fromJSON(arr)
	for i, k in pairs(arr) do
		local id = (#arr+1)-i
		PData["gps"][id] = createRadarArea(k[1]-10, k[2]-10, 20,20, 210,0,0,255)
		setElementData(PData["gps"][id], "coord", toJSON({k[1],k[2],k[3]}))
	end
	UpdateGPSMap()
end
addEvent("SetGPS", true)
addEventHandler("SetGPS", localPlayer, SetGPS)



function GetCursorPositionOnMap() -- Можно оптимизировать в дальнейшем
	local _,_,x,y,z = getCursorPosition()
	local camx, camy, camz = getCameraMatrix()
	
	local x2, y2, z2 = camx-x, camy-y, camz-z
	for i = 0, math.round(z2, 0) do
		local per = (i/math.round(z2, 0))
		if(z+(z2*per) >= 4000) then
			return x+(x2*per),y+(y2*per),z+(z2*per)
		end
	end
	return x,y,z
end


function updateCamera()
	if(getDevelopmentMode()) then
	
		for _, thePed in pairs(getElementsByType("ped", getRootElement(), true)) do
			local path = getElementData(thePed, "path")
			if(path) then
				for i, dat in pairs(path) do
					if(path[i+1]) then
						dxDrawLine3D(path[i][1], path[i][2], path[i][3]+1, path[i+1][1], path[i+1][2], path[i+1][3]+1, tocolor (255, 0, 0, 230), 2)
					end
				end
			end
		end
	
	
	
		local px,py,pz = getElementPosition(localPlayer)
	
		local material = GetGroundMaterial(px,py,pz,pz-2, getPlayerCity(localPlayer))
		local out = "Материал: "..material.."\nЗона: "..exports["ps2_weather"]:GetZoneName(px,py,pz, false, getElementData(localPlayer, "City"))
		if(isCursorShowing()) then
			local x,y,z = getCameraMatrix()
			local sx,sy, cx,cy,cz = getCursorPosition()
			local _,_,_,_,hitElement,_,_,_,_,_,_,model = processLineOfSight(x,y,z, cx,cy,cz, true,true,true, true, true, true, false, true, false, true, false)
			
			dxDrawLine3D(x,y,z, cx,cy,cz)
			if(model) then
				out = out.."\nЭлемент: "..model
			end
		end
		dxDrawBorderedText(out, 10, screenHeight/3, 10, screenHeight, tocolor(255, 255, 255, 255), NewScale*2, "default-bold", "left", "top", nil, nil, nil, true)


	
	
		for i, arr in pairs(PData["changezone"]) do
			
			local wx,wy,wz = false, false, false
			if(arr[2]) then
				wx,wy,wz = arr[2][1], arr[2][2], arr[2][3]
			else
				local _, _, worldx, worldy, worldz = getCursorPosition()
				local px, py, pz = getCameraMatrix()
				_,wx,wy,wz,_ = processLineOfSight(px, py, pz, worldx, worldy, worldz)
				wx,wy,wz = math.round(wx, 0), math.round(wy, 0), math.round(wz, 1)
				
			end
			local color = tocolor(50,150,200,80)
			if(arr[1][4] ~= getZoneName(wx,wy,wz, false)) then
				color = tocolor(200,50,50,80)
			end
	
			
			local point = {arr[1][1], wy, math.round(getGroundPosition(arr[1][1], wy, arr[1][3]+3), 1)}
			local point2 = {wx, arr[1][2], math.round(getGroundPosition(wx, arr[1][2], wz+3), 1)}
			
			dxDrawLine3D(arr[1][1], arr[1][2], arr[1][3], point[1], point[2], point[3], color, 25)
			
			dxDrawLine3D(point[1], point[2], point[3], wx,wy,wz, color, 25)
	
			dxDrawLine3D(wx,wy,wz, point2[1], point2[2], point2[3], color, 25)
	
			dxDrawLine3D(point2[1], point2[2], point2[3], arr[1][1], arr[1][2], arr[1][3], color, 25)
			
			
			local nx, ny = ((arr[1][1]-arr[2][1])/2), ((arr[1][2]-arr[2][2])/2)
			create3dtext('[ '..i..' ] ', arr[1][1]-nx, arr[1][2]-ny, arr[1][3]+2, NewScale*2, 60, tocolor(228, 70, 70, 180), "default-bold")
	
		end
	
	
		for zone, arr in pairs(PathNodes[getPlayerCity(localPlayer)]) do
			for i, arr2 in pairs(arr) do
				local x,y,z = arr2[2], arr2[3], arr2[4]
				
				local px,py,pz = getElementPosition(localPlayer)
				if(getDistanceBetweenPoints2D(x,y, px, py) < 300) then
					local text = '['..i..'] '..zone
					if(arr2[5]) then
						if(trafficlight[tostring(getTrafficLightState())] == arr2[5]) then
							text = text.." #e446fa["..arr2[5].."]"
						else
							text = text.." #32CD32["..arr2[5].."]"
						end
					end
					create3dtext(text, x,y,z+1, NewScale*2, 60, tocolor(228, 250, 70, 180), "default-bold")
					local nextmarkers = {}
					if(arr2[6]) then
						for _,k in pairs(arr2[6]) do
							table.insert(nextmarkers, {k[1], k[2]})
						end
					end
					
					if(PathNodes[getPlayerCity(localPlayer)][zone][i+1]) then
						table.insert(nextmarkers, {zone, i+1})
					end
					
					for _, arr3 in pairs(nextmarkers) do
						local dat = PathNodes[getPlayerCity(localPlayer)][arr3[1]][arr3[2]]
						local color = tocolor(50,255,50,150)
						if(dat[1] == "Closed" or arr2[1] == "Closed") then
							color = tocolor(255,50,50,150)
						end
						local x2,y2,z2 = dat[2], dat[3], dat[4]
						
						dxDrawLine3D(x,y,z+0.2,x2,y2,z2+0.2, color, 6)
						
						
						local a3,b3,c3 = getPointInFrontOfPoint(x2,y2,z2, findRotation(x,y,x2,y2)-60, 2)
						local a4,b4,c4 = getPointInFrontOfPoint(x2,y2,z2, findRotation(x,y,x2,y2)-120, 2)
						
						dxDrawLine3D(x2,y2,z2+0.2,a3,b3,c3+0.2, color, 6)
						dxDrawLine3D(x2,y2,z2+0.2,a4,b4,c4+0.2, color, 6)
					end
				end
			end
		end
	end
	
	if(PData["ResourceMap"]) then
		for i, dat in pairs(PData["ResourceMap"]) do
			for name, v in pairs(dat) do
				dxDrawLine3D(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8])
			end
		end
		local x,y,z = getElementPosition(localPlayer)
		mousex,mousey,mousez = GetCursorPositionOnMap()
		mx,my,mz = GetCoordOnMap(x,y,z)
		sx,sy = getScreenFromWorldPosition(mx,my,mz)
		if(sx and sy) then
			dxDrawCircle(sx,sy, 12*NewScale, 0, 360, tocolor(255,24,20,150))
			if(getDistanceBetweenPoints2D(mx,my,mousex,mousey) < 1) then
				Create3DTextOnMap("ТЫ",mousex*50,mousey*50,mousez,NewScale*2,2000,tocolor(230,230,230,255),"default-bold")
			end
		end
		
		if(isElement(PData["WaypointBlip"])) then
			local x,y,z = getElementPosition(PData["WaypointBlip"])
			mx,my,mz = GetCoordOnMap(x,y,z)
			sx,sy = getScreenFromWorldPosition(mx,my,mz)
			if(sx and sy) then
				dxDrawCircle(sx,sy, 12*NewScale, 0, 360, tocolor(255,24,20,150))
			end
		
		end
		tw = dxGetTextWidth(getPlayerCity(localPlayer), NewScale*3, "bankgothic", true)
		th = dxGetFontHeight(NewScale*3, "bankgothic")
		dxDrawBorderedText(getPlayerCity(localPlayer), screenWidth/2-tw/2.15, screenHeight-(screenHeight-th/10), screenWidth, screenHeight, tocolor(255, 255, 255, 255), NewScale*3, "bankgothic", nil, nil, nil, nil, nil, true)
		
		
		if(getPlayerCity(localPlayer) == "San Andreas") then
			Create3DTextOnMap("Los Santos\n#ffff00★★★★",1850,-1600,4000,NewScale*2,600,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("San Fierro\n#ffff00★★★",-2200,400,4000,NewScale*2,600,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Las Venturas\n#ffff00★★★",2200,1650,4000,NewScale*2,600,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Angel Pine\n#ffff00★★",-2150,-2450,4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Las Payasadas\n#ffff00★★★",-250,2650,4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("El Quebrados\n#ffff00★★★",-1500,2500,4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Fort Caston\n#ffff00★★",-245,1100,4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Palomino Creek\n#ffff00★★★",2350,30,4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Blueberry\n#ffff00★★★",215,-215,4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Dillimore\n#ffff00★",670,-540,4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Montgomery\n#ffff00★",1310, 310,4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Bayside\n#ffff00★",-2537, 2332,4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Las Barrancas\n#ffff00★",-763, 1504, 4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
		elseif(getPlayerCity(localPlayer) == "Liberty City") then
			Create3DTextOnMap("Portland\n#ffff00★★★",980, 438, 4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Staunton Island\n#ffff00★★★★",72, 72, 4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Shoreside Vale\n#ffff00★★",-935, 1050, 4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
		elseif(getPlayerCity(localPlayer) == "Vice City") then
			Create3DTextOnMap("Downtown\n#ffff00★★★★",-430, 830, 4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Prawn Island\n#ffff00★",263, 784, 4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Vice Point\n#ffff00★★",680, 316, 4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Starfish Island\n#ffff00★★★",-200, -646, 4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Little Haiti\n#ffff00★",-708, -115, 4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Little Havana\n#ffff00★", -743, -916, 4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Ocean Beach\n#ffff00★★★★", 570, -1125, 4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Washington Beach\n#ffff00★★", 275, -1530, 4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
			Create3DTextOnMap("Viceport\n#ffff00★", -542, -1605, 4000,NewScale*2,250,tocolor(230,230,230,255),"default-bold")
		end
		
		PData["MapHitElement"] = false
		local col = createObject(16635, mousex,mousey,mousez)
		for _, v in pairs(getElementsByType("colshape", getRootElement(), true)) do
			if(isElementWithinColShape(col, v)) then
				PData["MapHitElement"] = getElementAttachedTo(v)
			end
		end
		destroyElement(col)
		

		if(PData["MapHitElement"]) then
			x,y,z = getElementPosition(PData["MapHitElement"])
			--Create3DTextOnMap(getElementData(PData["MapHitElement"], "NameInMap"),x*50,y*50,z,NewScale,2000,tocolor(230,230,230,255),"default-bold")
		end
	end
	


	if(PData["ResourceMap"]) then
		if(getPlayerCity(localPlayer) == "Vice City") then
			setSkyGradient(80,120,180, 80,120,180)
		else
			setSkyGradient(170,103,0 ,170,103,0)
		end
		--setSkyGradient(0,0,0 ,0,0,0)
		setFarClipDistance(3000)
		setFogDistance(3000)
		setHeatHaze(0)
		setWeather(0)
		setCloudsEnabled(false)
	end
	
	
	
	
	
	if(PData["gps"]) then
		local px,py,pz = getElementPosition(localPlayer)
		
		if(#PData["gps"] == 0) then
			PData["gps"] = nil
		else
			for k,el in pairs(PData["gps"]) do
				if(isInsideRadarArea(el, px, py)) then
					for slot = k, #PData["gps"] do
						destroyElement(PData["gps"][slot])
						PData["gps"][slot] = nil
					end
					break
				end
			end
		end
		
		local oldmarker = false
		for i,v in pairs(PData["gps"]) do --тут
			if(oldmarker) then
				local x,y,z = unpack(fromJSON(getElementData(v, "coord")))
	
				if(getDistanceBetweenPoints2D(x,y, px, py) < 100) then
					local x2,y2,z2 = unpack(fromJSON(getElementData(oldmarker, "coord")))
	
					local a3,b3,c3 = getPointInFrontOfPoint(x,y,z, findRotation(x,y,x2,y2)-60, 2)
					local a4,b4,c4 = getPointInFrontOfPoint(x,y,z, findRotation(x,y,x2,y2)-120, 2)
					
					dxDrawLine3D(x,y,z+0.2,a3,b3,c3+0.2, tocolor(50,150,200,80), 6)
					dxDrawLine3D(x,y,z+0.2,a4,b4,c4+0.2, tocolor(50,150,200,80), 6)
					dxDrawLine3D(a3,b3,c3+0.2,a4,b4,c4+0.2, tocolor(50,150,200,80), 6)
				end
			end
			oldmarker = v
		end
	
	end
end
addEventHandler("onClientRender", getRootElement(), updateCamera)




function Create3DTextOnMap(text,x,y,z,razmer,dist,color,font)
	x = x/50
	y = y/50
	local px,py,pz = getCameraMatrix()
    local distance = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
    if distance <= dist then
		sx,sy = getScreenFromWorldPosition(x, y, z, 0.06)
		if not sx then return end
		dxDrawBorderedText(text, sx, sy, sx, sy, color, (1-(distance/dist))*razmer, font, "center", "bottom", false, false, false,false)
    end
end






function playerPressedKey(button, press)
	if(PData["ResourceMap"]) then
		if(press) then
			if(isTimer(PData["MovementMapTimer"])) then
				killTimer(PData["MovementMapTimer"])
			end
			PData["MovementMapSpeed"] = 1
		else
			if(isTimer(PData["MovementMapTimer"])) then killTimer(PData["MovementMapTimer"]) end
		end
		if(button == "w") then
			if(press) then
				PData["MovementMapTimer"] = setTimer(function() 
					local x,y,z,rx,ry,rz,r,f = getCameraMatrix()
					setCameraMatrix(x,y+PData["MovementMapSpeed"],z,rx,ry+PData["MovementMapSpeed"],rz,r,f)
					PData["MovementMapSpeed"] = PData["MovementMapSpeed"]+0.3
				end, 50, 0)
			end
		elseif(button == "s") then
			if(press) then
				PData["MovementMapTimer"] = setTimer(function() 
					local x,y,z,rx,ry,rz,r,f = getCameraMatrix()
					setCameraMatrix(x,y-PData["MovementMapSpeed"],z,rx,ry-PData["MovementMapSpeed"],rz,r,f)
					PData["MovementMapSpeed"] = PData["MovementMapSpeed"]+0.3
				end, 50, 0)
			end
		elseif(button == "a") then
			if(press) then
				PData["MovementMapTimer"] = setTimer(function() 
					local x,y,z,rx,ry,rz,r,f = getCameraMatrix()
					setCameraMatrix(x-PData["MovementMapSpeed"],y,z,rx-PData["MovementMapSpeed"],ry,rz,r,f)
					PData["MovementMapSpeed"] = PData["MovementMapSpeed"]+0.3
				end, 50, 0)
			end
		elseif(button == "d") then
			if(press) then
				PData["MovementMapTimer"] = setTimer(function() 
					local x,y,z,rx,ry,rz,r,f = getCameraMatrix()
					setCameraMatrix(x+PData["MovementMapSpeed"],y,z,rx+PData["MovementMapSpeed"],ry,rz,r,f)
					PData["MovementMapSpeed"] = PData["MovementMapSpeed"]+0.3
				end, 50, 0)
			end	
		elseif(button == "mouse_wheel_down") then
			if(press) then
				local x,y,z,rx,ry,rz,r,f = getCameraMatrix()
				if(z < 4250) then
					setCameraMatrix(x,y+2,z+10,rx,ry,rz,r,f)
				end
			end
		elseif(button == "mouse_wheel_up") then
			if(press) then
				local x,y,z,rx,ry,rz,r,f = getCameraMatrix()
				if(z > 4010) then
					setCameraMatrix(x,y-2,z-10,rx,ry,rz,r,f)
				end
			end
		elseif(button == "mouse2") then
			if(press) then
				if(isElement(PData["WaypointBlip"])) then
					destroyElement(PData["WaypointBlip"])
				else
					local x,y,z = GetCursorPositionOnMap()
					PData["WaypointBlip"] = createBlip(x*50, y*50, 0, 41, 2, 255,255,255, 0, 65535)
					local px,py,pz = getElementPosition(localPlayer)
					triggerServerEvent("GetPathByCoordsNEW", localPlayer, localPlayer, px, py, pz, x*50, y*50, 20)
					--[[triggerServerEvent("saveserver", localPlayer, localPlayer, 
					x*50, y*50, 20, 
					x*50, y*50, 20, "PedPath")--]]
				end
			end
		end
	end
end
addEventHandler("onClientKey", root, playerPressedKey)


function GetVehicleNodesClient()
	return PathNodes
end


function resourcemap()
	if(not PData["ResourceMap"]) then
		setElementFrozen(localPlayer, true)
		local theVehicle = getPedOccupiedVehicle(localPlayer)
		if(theVehicle) then
			setElementFrozen(theVehicle, true)
		end
		map()
	else
		setCameraTarget(localPlayer)
		PData["ResourceMap"] = nil
		
		if(PData["BizControlName"]) then
			triggerServerEvent("StopBizControl", localPlayer, PData["BizControlName"][1]) 
			PText["biz"] = {}
			PData["MapShowInfo"] = nil
			PData["BizControlName"] = nil
			PInv["shop"] = {} 
			PBut["shop"] = {} 
		end
		
		
		setElementFrozen(localPlayer, false)
		local theVehicle = getPedOccupiedVehicle(localPlayer)
		if(theVehicle) then
			setElementFrozen(theVehicle, false)
		end
		showCursor(false)
	end
end
addEvent("ResourceMap", true)
addEventHandler("ResourceMap", getRootElement(), resourcemap)
bindKey("F10", "down", resourcemap)







function GetGroundMaterial(x,y,z,gz,city)
	x, y = math.round(x, 0), math.round(y, 0)
	local material = false
	local zone = exports["ps2_weather"]:GetZoneName(x,y,z, true, city)
	if(GroundMaterial[city]) then
		if(GroundMaterial[city][zone]) then
			if(GroundMaterial[city][zone][x]) then
				if(GroundMaterial[city][zone][x][y]) then
					material = GroundMaterial[city][zone][x][y]
				end
			end
		end
	end
	if(not material) then _,_,_,_,_,_,_,_,material = processLineOfSight(x,y,z,x,y,gz-1, true,false,false,false,false,true,true,true,localPlayer, true) end
	if(not material) then material = 1337 end
	return material
end
addEvent("GetGroundMaterial", true)
addEventHandler("GetGroundMaterial", getRootElement(), GetGroundMaterial)





function addLabelOnClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if(getDevelopmentMode()) then
		worldX = math.round(worldX, 0)
		worldY = math.round(worldY, 0)
		worldZ = math.round(worldZ, 1)
		if(button == "left") then
			if(getKeyState("lctrl")) then
				if(state == "down") then
					PData['changezone'][#PData['changezone']+1] = {[1] = {worldX, worldY, worldZ, getZoneName(worldX, worldY, worldZ, false)}}
				else
					local zone = getZoneName(worldX, worldY, worldZ, false)
					if(zone == PData['changezone'][#PData['changezone']][1][4]) then
						local oldx, oldy, oldz = PData['changezone'][#PData['changezone']][1][1], PData['changezone'][#PData['changezone']][1][2], PData['changezone'][#PData['changezone']][1][3]
				
		
						local out = {oldx, oldy, oldz, worldX, worldY, worldZ}
						if(out[1] > out[4]) then
							out = {out[4], out[2], math.round(getGroundPosition(out[4], out[2], out[3]+3), 1), out[1], out[5], math.round(getGroundPosition(out[1], out[5], out[6]+3), 1)}
						end
						
						if(out[2] > out[5]) then
							out = {out[1], out[5], math.round(getGroundPosition(out[1], out[5], out[3]+3), 1), out[4], out[2], math.round(getGroundPosition(out[4], out[2], out[6]+3), 1)}
						end
						
			
						PData['changezone'][#PData['changezone']][1] = {out[1], out[2], out[3], zone}
						PData['changezone'][#PData['changezone']][2] = {out[4], out[5], out[6]}
						
		
						triggerServerEvent("saveserver", localPlayer, localPlayer, 
						out[1], out[2], out[3], 
						out[4], out[5], out[6], "PedPath"
						)
					else
						PData['changezone'][#PData['changezone']] = nil
					end
				end
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), addLabelOnClick)






function create3dtext(text,x,y,z,razmer,dist,color,font)
	local px,py,pz = getCameraMatrix()
    local distance = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
    if distance <= dist then
		if(getPedOccupiedVehicle(localPlayer)) then
			if(isLineOfSightClear(x,y,z, px,py,pz, true, false, false, true, false, false, false, localPlayer)) then
				sx,sy = getScreenFromWorldPosition(x, y, z, 0.06)
				if not sx then return end
				MemText(text, sx, sy, color, razmer, font, razmer, 0, true, true, dist/(dist-distance))
			end
		else
			if(isLineOfSightClear(x,y,z, px,py,pz, true, true, false, true, false, false, false, localPlayer)) then
				sx,sy = getScreenFromWorldPosition(x, y, z, 0.06)
				if not sx then return end
				MemText(text, sx, sy, color, razmer, font, razmer, 0, true, true, dist/(dist-distance))
			end
		end
    end
end



function MemText(text, left, top, color, scale, font, border, incline, centerX, centerY, scale3D)
	if(text) then
		local index = text..color
		if(not border) then border = 1 end
		local w,h = dxGetTextWidth(text, scale, font, true)+(border*2), dxGetFontHeight(scale, font)+(border*2)
		
		
		if(not VideoMemory["HUD"][index]) then
			VideoMemory["HUD"][index] = dxCreateRenderTarget(w+((w*incline)/4),h, true)
		end
		
		dxSetRenderTarget(VideoMemory["HUD"][index], true)
		dxSetBlendMode("modulate_add")
		
		local posx, posy = ((w*incline)/4),0
		if(border) then
			posx = posx+border
			posy = posy+border
		end
		
		
		local textb = string.gsub(text, "#%x%x%x%x%x%x", "")
		for oX = -border, border do 
			for oY = -border, border do 
				dxDrawText(textb, posx+oX, posy+oY, 0+oX, 0+oY, tocolor(0, 0, 0, 255), scale, font, "left", "top", false, false,false,false)
			end
		end

		dxDrawText(text, posx, posy, 0, 0, color, scale, font, "left", "top", false,false,false,true)

		
		dxSetBlendMode("blend")
		dxSetRenderTarget()
		
		
		if(incline > 0) then 
			local pixels = dxGetTexturePixels(VideoMemory["HUD"][index])
			local x, y = dxGetPixelsSize(pixels)
			local texture = dxCreateTexture(x,y, "argb")
			local pixels2 = dxGetTexturePixels(texture)
			local pady = 0
			for y2 = 0, y-1 do
				for x2 = 0, x-1 do
					local colors = {dxGetPixelColor(pixels, x2,y2)}
					if(colors[4] > 0) then
						dxSetPixelColor(pixels2, x2-pady, y2, colors[1],colors[2],colors[3],colors[4])
					end
				end
				pady = pady+incline
			end
			
			dxSetTexturePixels(texture, pixels2)
			VideoMemory["HUD"][index] = texture
		end
		
		if(scale3D) then 
			w = w/scale3D 
			h = h/scale3D
		end
		
		if(centerX) then 
			if(centerX == "right") then 
				left = left-(w) 
			else
				left = left-(w/2) 
			end
		end
		
		if(centerY) then 
			if(centerY == "bottom") then 
				top = top-(h) 
			else
				top = top-(h/2)
			end
		end
		
		return dxDrawImage(left,top, w,h, VideoMemory["HUD"][index], 0, 0, 0, color) 
	end
end





function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

 
function getPointInFrontOfPoint(x, y, z, rZ, dist)
	local offsetRot = math.rad(rZ)
	local vx = x + dist * math.cos(offsetRot)
	local vy = y + dist * math.sin(offsetRot)  
	return vx, vy, z
end







function getPlayerCity(thePlayer)
	return getElementData(thePlayer, "City") or "San Andreas"
end






function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end




function dxDrawBorderedText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning)
	if(text) then
		local r,g,b = bitExtract(color, 0, 8), bitExtract(color, 8, 8), bitExtract(color, 16, 8)
		if(r+g+b >= 100) then r = 0 g = 0 b = 0 else r = 255 g = 255 b = 255 end
		local textb = string.gsub(text, "#%x%x%x%x%x%x", "")
		local locsca = math.round(scale, 0)
		if (locsca == 0) then locsca = 1 end
		for oX = -locsca, locsca do 
			for oY = -locsca, locsca do 
				dxDrawText(textb, left + oX, top + oY, right + oX, bottom + oY, tocolor(r, g, b, bitExtract(color, 24, 8)), scale, font, alignX, alignY, clip, wordBreak,postGUI,false)
			end
		end

		dxDrawText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, true)
	end
end






