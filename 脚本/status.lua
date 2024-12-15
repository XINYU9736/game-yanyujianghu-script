require "detection"
require("common_define")

json = require "json"

detection = Detection

define_infos = detection_pos_info

local position_pattern = ".?(%d+)[^%d](%d+).?"

Status = {
	energy = 0,
    hungry = 0,
    silver = 0,
    gold = 0,
    time = 0,
    city = "",
    position = {0,0},
    interact = {}
}


function Status:updatepositon()
	tag = "position"
    local result2 = detection:ocr(detection_pos_info[tag][1],detection_pos_info[tag][2],detection_pos_info[tag][3],detection_pos_info[tag][4])
    local info  = json.decode(tostring(result2))
    --print(result2)
    if(not #info == 2)
    then
    	toast("Î»ÖÃÊ¶±ð´íÎó")
        sleep(500)
    else
    	local cityinfo = null
        local posinfo = null 
    	if(info[1]["x"]>info[2]["x"])
        then
        	cityinfo = info[2]
            posinfo = info[1]
        else
			cityinfo = info[1]
			posinfo = info[2]
        end
        --posinfo["label"] = string.gsub(posinfo["label"], "O", "0")
        --posinfo["label"] = string.gsub(posinfo["label"], "o", "0")
        --posinfo["label"] = string.gsub(posinfo["label"], "Z", "2")
        --posinfo["label"] = string.gsub(posinfo["label"], "z", "2")
        --posinfo["label"] = string.gsub(posinfo["label"], "I", "1")
    	Status.city = cityinfo["label"]
        local r1,r2 = string.match(posinfo["label"],position_pattern)
        Status.position[1] = tonumber(r1)
        Status.position[2] = tonumber(r2)
        --print(Status.position[1],Status.position[2])
    end
    print(Status.city,Status.position[1],Status.position[2])
end




