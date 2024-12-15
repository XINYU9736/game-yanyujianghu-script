local Loader = {}
function Loader:init(apkPath, context)
    -- Load the APK
    local MyAppClass = loader.loadClass("com.example.myapp.MyApplication")
    local myAppInstance = MyAppClass.newInstance()

    -- Attach the context
    local attachMethod = MyAppClass.getDeclaredMethod("attachBaseContext", context:getClass())
    attachMethod:setAccessible(true)
    attachMethod:invoke(myAppInstance, context)

    -- Call onCreate
    myAppInstance:onCreate()
end
return Loader