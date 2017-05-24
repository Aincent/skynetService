local skynet    = require "skynet.manager"
local TAG = 'main'

local function start_gateServer()
	-- 整个server的控制层
	local pGateServer = skynet.newservice("gateServerService")
	skynet.name(".GateServer", pGateServer)
	Log.d(TAG, "pGateServer = %s", pGateServer)
	-- 获取等级和端口
	local level = tonumber(skynet.getenv("level"))
	local port = tonumber(skynet.getenv("port"))  -- 也用做serverId
	local pRet = skynet.call(pGateServer, "lua", "init", level, port)
end

skynet.start(function()
    Log.e(TAG, "GateServer start")
    start_gateServer()
end)
