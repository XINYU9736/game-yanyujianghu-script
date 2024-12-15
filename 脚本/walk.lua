require "map_datas"
require("common_define")
require("map_proc")

 	--默认中视角，1920*1080

maps = Global_Map_Datas
citylists = Global_City_Lists
mmap_prc = Map_Proc

Pre_defines = {
	zoom_ratio = 1,
	stepx = 216,
	stepy = 108,
	leftoffset = 54,
	rightoffset = 300,
	topoffset = 81,
	bottomoffset = 100,
    centerx = 0,
    centery = 0,
}

Pre_defines.centerx = 0.5*(machine_parameters["width"]-Pre_defines.leftoffset-Pre_defines.rightoffset)+Pre_defines.leftoffset
Pre_defines.centery = 0.5*(machine_parameters["height"]-Pre_defines.topoffset-Pre_defines.bottomoffset)+Pre_defines.topoffset

--print(Pre_defines.centerx,Pre_defines.centery)

Walk = {

}

function Walk:calPointDist(rep,dtp)
	--print("calPointDist",rep,dtp)
	return math.abs(dtp[1]-rep[1])+math.abs(dtp[2]-rep[2])
end

function Walk:CalCurrentPixel(ccity,cpos)
	--print(cpos[1],cpos[2],maps[ccity]["width"],maps[ccity]["height"])
	local current_Pixel = {Pre_defines.centerx,Pre_defines.centery}
	local mapsize = {maps[ccity]["width"],maps[ccity]["height"]}
    local sumPixelx = maps[ccity]["width"]*0.5*Pre_defines.stepx+maps[ccity]["height"]*0.5*Pre_defines.stepx
    local sumPixely = maps[ccity]["width"]*0.5*Pre_defines.stepy+maps[ccity]["height"]*0.5*Pre_defines.stepy
    --计算到四个边的像素距离
    local topDisPixel = cpos[1]*0.5*Pre_defines.stepy+cpos[2]*0.5*Pre_defines.stepy
    local leftDisPixel = cpos[1]*0.5*Pre_defines.stepx+(maps[ccity]["height"]-cpos[2])*0.5*Pre_defines.stepx
    --print(topDisPixel,leftDisPixel,sumPixelx-leftDisPixel,sumPixely-topDisPixel)
    if(leftDisPixel<Pre_defines.centerx) 
    then
    	current_Pixel[1] = leftDisPixel+Pre_defines.leftoffset
    elseif((sumPixelx-leftDisPixel)<Pre_defines.centerx)
    then
    	current_Pixel[1] = machine_parameters["width"]-sumPixelx+leftDisPixel
    elseif(topDisPixel<Pre_defines.centery)
	then
		current_Pixel[2] = topDisPixel+Pre_defines.topoffset
    elseif((sumPixely-topDisPixel)<Pre_defines.centery)
	then
		current_Pixel[2] = machine_parameters["height"]-sumPixely+topDisPixel
    end
    --print(current_Pixel[1],current_Pixel[2])
    return current_Pixel
end

function Walk:GoTo(cp,rstpos,dstpos)
	print("tap",rstpos[1],rstpos[2],dstpos[1],dstpos[2])
	local dstx = (dstpos[1] - rstpos[1])*Pre_defines.stepx*0.5 - (dstpos[2] - rstpos[2])*Pre_defines.stepx*0.5
    local dsty = (dstpos[1] - rstpos[1])*Pre_defines.stepy*0.5 + (dstpos[2] - rstpos[2])*Pre_defines.stepy*0.5
    --print(cp[1]+dstx,cp[2]+dsty)
    tap(cp[1]+dstx,cp[2]+dsty)
end

function Walk:GoPath(status,fpath,step)
	status:updatepositon()
	local cp = walk:CalCurrentPixel(status["city"],status["position"])
    local pindex = 1
	for i=1,#fpath do
    	if(Walk:calPointDist(status["position"],fpath[i])==step or i==#fpath) then
        	pindex = i
            Walk:GoTo(cp,status["position"],fpath[i])
            local timeout = 0
            while(Walk:calPointDist(status["position"],fpath[i])>0)do
            	status:updatepositon()
                timeout = timeout+1
                if(timeout>10)then
                	return false
                end
                sleep(100*step)
            end
            sleep(200)
        end
    end
    status:updatepositon()
    if(Walk:calPointDist(status["position"],fpath[#fpath])==0)then
    	return true
    else
    	return false
    end
end


function Walk:GoThroughMaps(status,dstcity,dstlabel)
	status:updatepositon()
    if(status["city"] ~= dstcity) then 
    	local citylist = citylists[status["city"]][dstcity]
        for i=1,#citylist-1 do
        	local next_city = citylist[i+1]
        	local pt = mmap_prc:searchfullRoad(status["city"],status["position"],next_city)
            Walk:GoPath(status,pt,5)
            local timeout = 0
			while(status["city"]~=next_city)do
				status:updatepositon()
				timeout = timeout+1
				if(timeout>100)then
					return false
				end
				sleep(500)
			end
            sleep(500)
        end
    end	
    local pt = mmap_prc:searchfullRoad(status["city"],status["position"],dstlabel)
	Walk:GoPath(status,pt,5)
end

