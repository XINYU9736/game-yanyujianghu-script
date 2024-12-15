require "map_datas"

globalmap = Global_Map_Datas

objlabel = LandformNames

local max_step = 5
local roadnum = objlabel["道路"]

Map_Proc = {
	find = nil
}

function Map_Proc:checkPoint(mapsize,cpos)
	if(cpos[1]<0)then
		cpos[1] = 0
	end
	if(cpos[2]<0)then
		cpos[2] = 0
	end
	if(cpos[1]>mapsize[1])then
		cpos[1]  = mapsize[1]
	end
	if(cpos[2]>mapsize[2])then
		cpos[2]  = mapsize[2]
	end
    return cpos
end

function Map_Proc:GetTargetPos(cityname,targetstring)
	--local map_meta_data = globalmap[cityname]["arr"]
    local cityreource = globalmap[cityname]["resource"]
    local dstpos ={0,0}
    for key,value in pairs(cityreource) do
		if(value["name"] == targetstring)
		then
			dstpos[1] = tonumber(cityreource[key]["x"])
			dstpos[2] = tonumber(cityreource[key]["y"])
			return dstpos
		end
    end
    return dstpos
end


function Map_Proc:ifPointPassable(mapdata,mapsize,cpos)
	local ret = false
	if( cpos[1]>mapsize[1] or cpos[2]>mapsize[2] or cpos[1]<0 or cpos[2]<0)then
  		ret = false
    else 
    	local pointlable = mapdata[cpos[1]+1][cpos[2]+1]
		if(pointlable == objlabel["道路"] or pointlable == objlabel["建筑"] )then
			ret = true
		end  
    end
    --print(cpos[1],cpos[2],ret)
    return ret
end

function Map_Proc:getDirection(cx,tx)
	if(cx==tx) then
    	return 0
	elseif(cx<tx) then
    	return 1
    else
    	return -1
	end    
end

function Map_Proc:calPointDist(rep,dtp)
	--print("calPointDist",rep,dtp)
	return math.abs(dtp[1]-rep[1])+math.abs(dtp[2]-rep[2])
end


function Map_Proc:getNearPassablePoint(mapdata,mapsize,cpos,tpos,mstep)
	local xdir = Map_Proc:getDirection(cpos[1],tpos[1])
	local ydir = Map_Proc:getDirection(cpos[2],tpos[2])
	for xstep=0,mstep do
     	for ystep=0,mstep-xstep do
        	if(Map_Proc:ifPointPassable(mapdata,mapsize,{cpos[1]+xstep*xdir,cpos[2]+ystep*ydir})) then
        		local nextpoit = {cpos[1]+xstep*xdir,cpos[2]+ystep*ydir}
                return nextpoit
            end
            if(Map_Proc:ifPointPassable(mapdata,mapsize,{cpos[1]-xstep*xdir,cpos[2]+ystep*ydir})) then
				local nextpoit = {cpos[1]-xstep*xdir,cpos[2]+ystep*ydir}
				return nextpoit
			end
            if(Map_Proc:ifPointPassable(mapdata,mapsize,{cpos[1]+xstep*xdir,cpos[2]-ystep*ydir})) then
				local nextpoit = {cpos[1]+xstep*xdir,cpos[2]-ystep*ydir}
				return nextpoit
			end
            if(Map_Proc:ifPointPassable(mapdata,mapsize,{cpos[1]-xstep*xdir,cpos[2]-ystep*ydir})) then
				local nextpoit = {cpos[1]-xstep*xdir,cpos[2]-ystep*ydir}
				return nextpoit
			end
        end 
    end
    return nil
end

function Map_Proc:isPointinTable(rtable,item)
	if(#rtable == 0)then
    	return false
    end
	for i=1,#rtable do
    	--print("calPointDist",rtable[i],item)
    	if(Map_Proc:calPointDist(rtable[i],item)==0) then
        	return true
        end
    end
    return false
end

function Map_Proc:searchCrossPoint(mapdata,mapsize,tpos,cpath,desertlist)
	local cpos = cpath[#cpath]
    local pointlist = {
    	{cpos[1]+1,cpos[2]},
        {cpos[1],cpos[2]+1},
        {cpos[1]-1,cpos[2]},
        {cpos[1],cpos[2]-1}
    }
    local minpointdst = 100
    local minpointindex = 0
	for i=1,#pointlist do
    	if(Map_Proc:isPointinTable(cpath,pointlist[i])==false) then
			local isindesertlist = Map_Proc:isPointinTable(desertlist,pointlist[i])
			local ispointpassbale = Map_Proc:ifPointPassable(mapdata,mapsize,pointlist[i])
			if(isindesertlist==false and ispointpassbale==true) then
				local pointdst = Map_Proc:calPointDist(pointlist[i],tpos)
				if(pointdst<minpointdst) then 
					minpointdst = pointdst
					minpointindex = i
				end
            end
        end
    end
    if(minpointindex>0) then
    	return pointlist[minpointindex]
    end
    return nil
end


function Map_Proc:searchfullRoad(cityname,cpos,targetstring)
    local mapsize = {globalmap[cityname]["width"],globalmap[cityname]["height"]}
    local mapdata = globalmap[cityname]["arr"]
    local tpos = Map_Proc:GetTargetPos(cityname,targetstring)
    print("寻找路线 , ","from:",cpos[1],cpos[2],",to:",tpos[1],tpos[2])
    local fpath = {cpos}
    local orindist = Map_Proc:calPointDist(cpos,tpos)
	if(orindist==0) then
		return fpath
    elseif(orindist==1) then
    	fpath[#fpath+1] = tpos
        return fpath
	end
	local cnearpoint = Map_Proc:getNearPassablePoint(mapdata,mapsize,cpos,tpos,max_step)
    local tnearpoint = Map_Proc:getNearPassablePoint(mapdata,mapsize,tpos,cpos,max_step)
    if(Map_Proc:calPointDist(cpos,cnearpoint)~=0) then
    	fpath[#fpath+1] = cnearpoint
    end
    if(Map_Proc:calPointDist(cnearpoint,tnearpoint)==0) then
    	fpath[#fpath+1] = tpos
		return fpath
	end    
    local desertlist = {}
	for i=0,mapsize[1]*mapsize[2] do
    	local fpoint = fpath[#fpath]
    	local fnewpoint = Map_Proc:searchCrossPoint(mapdata,mapsize,tpos,fpath,desertlist)
        --print(fnewpoint)
        --print(fpath)
        --print(desertlist)
        if(fnewpoint == nil)then
        	desertlist[#desertlist+1] = fpath[#fpath]
            table.remove(fpath,#fpath)
        --[[end
        if( #fpath>1 and Map_Proc:calPointDist(fnewpoint,fpath[#fpath-1])==0)then
        	desertlist[#desertlist+1] = fpath[#fpath]
            print("desertlist1",desertlist[#desertlist])
            table.remove(fpath,#fpath)
            if(#fpath>1)then
            	desertlist[#desertlist+2] = fpath[#fpath]
                print("desertlist2",desertlist[#desertlist])
            	table.remove(fpath,#fpath)
            end--]]
        else
        	fpath[#fpath+1] = fnewpoint
            if(Map_Proc:calPointDist(fnewpoint,tnearpoint)==0) then
				break
			end
        end
        
        --[[
        --print("fnewpoint",fnewpoint)
        local bnewpoint = Map_Proc:searchCrossPoint(mapdata,mapsize,bpath[#bpath],cpos)
		if(bnewpoint[1] == fpoint[1] and bnewpoint[2] == fpoint[2]) then
			break
		end
        bpath[#bpath+1] = bnewpoint]]--
    end
	if(Map_Proc:calPointDist(tnearpoint,tpos)~=0) then
		fpath[#fpath+1] = tpos
	end
    for i=1,#fpath-3 do
    	if(fpath[i+3] == nil) then
        	break
        end
    	if(Map_Proc:calPointDist(fpath[i],fpath[i+3])==1) then
        	--print("---debug:remove",fpath[i+1][1],fpath[i+1][2])
        	table.remove(fpath,i+1)
            --print("---debug:remove",fpath[i+1][1],fpath[i+1][2])
            table.remove(fpath,i+1)
        end
    end
	return fpath
end




function Map_Proc:searchWithDirection(mapdata,cpos,tpos)

    local cnewpoint = Map_Proc:checkPoint(mapsize,{cpos[1] - max_step*xdir,cpos[2] - max_step*ydir})
    local tnewpoint = Map_Proc:checkPoint(mapsize,{tpos[1] + max_step*xdir,tpos[2] + max_step*ydir})
    --寻找cnewpoint到tnewpoint的主路
    --每行搜索最长的路
    xmax_xroad_len = {}
    local xroadlist = {}
    for xstep=cnewpoint[1],tnewpoint[1] do
        local roadarray = {}
        local mapindex = {}
        local length = 0
        for ystep=cpos[2],tpos[2] do
        	if(Map_Proc:ifPointPassable(mapdata,{xstep,ystep}))then
            	roadarray[#roadarray+1] = {xstep,ystep}
                length  = length+1
            else
            	mapindex[length] = #xroadlist
                xroadlist[#roadlist+1] = roadarray
                roadarray = {}
                length = 0
            end
        end
        table.sort(mapindex)
    end
    
end

function Map_Proc:searchNextPoint(mapsize,mapdata,cpos)
	local tpointlist = {}
    local tindex = 1
	for yindex=1,max_step do
		local tmppoint = Map_Proc:checkPoint(mapsize,{cpos[1],cpos[2]-yindex})
		if(mapdata[tmppoint[1]+1][tmppoint[2]+1] == roadnum)then
			tpointlist[tindex] = tmppoint
			tindex = tindex+1
        end
		local tmppoint = Map_Proc:checkPoint(mapsize,{cpos[1],cpos[2]+yindex})
		if(mapdata[tmppoint[1]+1][tmppoint[2]+1] == roadnum)then
			tpointlist[tindex] = tmppoint
			tindex = tindex+1
     	end
    end
    for xindex=1,max_step do
		local tmppoint = Map_Proc:checkPoint(mapsize,{cpos[1]-xindex,cpos[2]})
		if(mapdata[tmppoint[1]+1][tmppoint[2]+1] == roadnum)then
			tpointlist[tindex] = tmppoint
			tindex = tindex+1
		end
		local tmppoint = Map_Proc:checkPoint(mapsize,{cpos[1]+xindex,cpos[2]})
		if(mapdata[tmppoint[1]+1][tmppoint[2]+1] == roadnum)then
			tpointlist[tindex] = tmppoint
			tindex = tindex+1
		end
    end
    return tpointlist
end

function Map_Proc:addNextPoint(mapsize,mapdata,cpath)
	local csize = #cpath
    local newpath = cpath
    for i=1,csize do
    	lastpos = cpath[i][#cpath[i]]
        local nextpoint = Map_Proc:searchNextPoint(mapsize,mapdata,lastpos)
        --newpath[i][#newpath[i]+1] = nextpoint[1]
        for k=1,#nextpoint do
        	local nextpointitem = nextpoint[k]
          	local tailpoint =  newpath[i][#newpath] 
            local dist = math.abs(tailpoint[1]-nextpointitem[1])+math.abs(tailpoint[2]-nextpointitem[2])
            if(dist==1)then
            	newpath[i][#newpath[i]+1] = nextpointitem
            else
            	newpath[#newpath+1]	= cpath[i]
                newpath[#newpath][#newpath[i]+1] = nextpoint[k]
            end
        end
        print("newpath",newpath)
       	break  
    end
	return newpath
end


function Map_Proc:getAllPath(cityname,cpos,dstname)
	local fullpath = {}
	local pathlist= {{cpos}}
    local mapsize = {globalmap[cityname]["width"],globalmap[cityname]["height"]}
    local mapdata = globalmap[cityname]["arr"]
    local tpos = Map_Proc:GetTargetPos(cityname,dstname)
    print("tpos",tpos)
    for i=0,math.max(mapsize[1],mapsize[2]) do
    	pathlist = Map_Proc:addNextPoint(mapsize,mapdata,pathlist)
        local maplen = #pathlist
        for i=1, 2 do
        	print("pathlist:",pathlist)
        	local lastpoint = pathlist[i][#pathlist[i]]
            print("lastpoint",lastpoint,tpos)
            local lastdist = math.abs(tpos[1]-lastpoint[1])+math.abs(tpos[2]-lastpoint[2])
        	if(lastdist<max_step) then
            	fullpath[#pathlist[i]] = pathlist[i]
            end
        end
        if(#fullpath>0)then
        	break
        end
    end
   	fullpath = table.sort(fullpath)
    print(fullpath[1])
    return fullpath[1]
end

function Map_Proc:GetFullPath(cityname,cpos,targetstring)
	
	local gopath = {}
    local tpos = Map_Proc:GetTargetPos(cityname,targetstring)
    local mapsize = {globalmap[cityname]["width"],globalmap[cityname]["height"]}
    local map_meta_data = globalmap[cityname]["arr"]
    --print(math.max(mapsize))
    --寻找起点终点最近的主路点
    local detx = 1
    local dety = 1
    if(tpos[1] < cpos[1])
    then
    	detx = -1
    end
    if(tpos[1] < cpos[1])
	then
		detx = -1
	end
    for i=0,math.max(mapsize[1],mapsize[2]) do
    	--print(i,cpos[1],cpos[2],map_meta_data[cpos[2]+i+1][cpos[1]+1])
        local startposa = {cpos[1]+i*detx,cpos[2]+i*dety}
        local startposd = {cpos[1]-i*detx,cpos[2]-i*dety}
    	if(startposa[1] < mapsize[1] and startposa[1] > 0 and map_meta_data[startposa[1]+1][cpos[2]+1]==objlabel["道路"])
    	then
    		gopath[1] = {startposa[1],cpos[2]}
        	break
    	elseif(startposd[1] < mapsize[1] and startposd[1] > 0 and map_meta_data[startposd[1]+1][cpos[2]+1]==objlabel["道路"])
        then
           	gopath[1] = {startposd[1],cpos[2]}
            break
      	elseif(startposa[2] < mapsize[2] and startposa[2] > 0 and map_meta_data[cpos[1]+1][startposa[2]+1]==objlabel["道路"])
      	then
      		gopath[1] = {cpos[1],startposa[2]}
        break
       	elseif(startposd[2] < mapsize[2] and startposd[2] > 0 and map_meta_data[cpos[1]+1][startposd[2]+1]==objlabel["道路"])
		then
			gopath[1] = {cpos[1],startposd[2]}
		break
      	end
    end
    for i=0,math.max(mapsize[1],mapsize[2]) do
		print(i,cpos[1],cpos[2],map_meta_data[19][13])
		local startposa = {tpos[1]+i*detx,tpos[2]+i*dety}
		local startposd = {tpos[1]-i*detx,tpos[2]-i*dety}
		if(startposa[1] < mapsize[1] and startposa[1] > 0 and map_meta_data[startposa[1]+1][tpos[2]+1]==objlabel["道路"])
		then
			gopath[-1] = {startposa[1],tpos[2]}
			break
		elseif(startposd[1] < mapsize[1] and startposd[1] > 0 and map_meta_data[startposd[1]+1][tpos[2]+1]==objlabel["道路"])
		then
			gopath[-1] = {startposd[1],tpos[2]}
			break
		elseif(startposa[2] < mapsize[2] and startposa[2] > 0 and map_meta_data[tpos[1]+1][startposa[2]+1]==objlabel["道路"])
		then
			gopath[-1] = {tpos[1],startposa[2]}
		break
		elseif(startposd[2] < mapsize[2] and startposd[2] > 0 and map_meta_data[tpos[1]+1][startposd[2]+1]==objlabel["道路"])
		then
			gopath[-1] = {tpos[1],startposd[2]}
		break
		end
	end
    
    print(gopath)
end

