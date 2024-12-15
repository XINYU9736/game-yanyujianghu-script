import('java.io.File')
import('java.lang.*')
import('java.util.Arrays')
import('android.content.Context')
import('com.nx.assist.lua.LuaEngine')
import('com.nx.assist.lua.PaddleOcr')

Detection ={
	foo=null
}

local modelDetPath = "/storage/emulated/0/Pictures/paddle_assets/det.onnx"
local modelClsPath = "/storage/emulated/0/Pictures/paddle_assets/cls.onnx"
local modelRecPath = "/storage/emulated/0/Pictures/paddle_assets/rec.onnx"
local detParams = "/storage/emulated/0/Pictures/paddle_assets/det.param"
local recParams = "/storage/emulated/0/Pictures/paddle_assets/rec.param"
local detBin = "/storage/emulated/0/Pictures/paddle_assets/det.bin"
local recBin = "/storage/emulated/0/Pictures/paddle_assets/rec.bin"
local keyTxt = "/storage/emulated/0/Pictures/paddle_assets/keys.txt"

--local r = PaddleOcr.loadNnccModel(detParams,recParams,detBin,recBin,keyTxt)
local r = PaddleOcr.loadModel(true)

function Detection:ocr(ltx,lty,rbx,rby)
	--print("ocr start")
	local bitmap = LuaEngine.snapShot(ltx,lty,rbx,rby)
    local str = PaddleOcr.detect(bitmap)
    LuaEngine.releaseBmp(bitmap)
    --print("ocr end")
    return str
end


--[[import('java.io.File')
import('java.lang.*')
import('java.util.Arrays')
import('android.content.Context')
import('android.hardware.Sensor')
import('android.hardware.SensorEvent')
import('android.hardware.SensorEventListener')
import('android.hardware.SensorManager')
import('android.graphics.BitmapFactory')
import('com.nx.assist.lua.LuaEngine')

Detection = {ocr=null}

function Detection:init()
	local loader = LuaEngine.loadApk("RapidOcrAndroidOnnxCompose-0.1.0-debug.apk")
    local OCR = loader.loadClass("com.benjaminwan.ocr.OcrApi")
    local context = LuaEngine.getContext()
    self.ocr = OCR.getInstance(context)
    local ret = self.ocr.setParams(50,0.6,0.3,true)
end

function Detection:new()
	Detection:init()
	local self = {}
    setmetatable(self,{__index = Detection})
   	return self
	
end

/storage/emulated/0/lril/paddle_assets
print("1")
local x=-1 y=-1
ret,x,y=findImage(0,0,1920,1080,"package.png",0.8)
if x~=-1 and y ~=-1 then
print(x,y)
end]]--