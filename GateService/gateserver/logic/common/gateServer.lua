local socketManager = require("byprotobuf/socketManager")
local socketCmd = require("logic/common/socketCmd")
local skynet = require "skynet"
local TAG = "GateServer"
local queue = require "skynet.queue"
local sharedata = require("sharedata")

local cs = queue()

local GateServer = class()

function GateServer:init(level, port)
	Log.d(TAG, "GateServer init")
	-- 数据初始化
	self.m_level = level
	assert(self.m_level)
	Log.d(TAG, "GateServer.m_level = %s", self.m_level)
	--开启监听Client的端口,管理GateServer与clinetWatchdog的链接 
	local watchdog = skynet.newservice("clientWatchdog")
	skynet.call(watchdog, "lua", "start",{
		port      = port,
		maxclient = 1024,
		nodelay   = true,
	})
	Log.e(TAG, "watchdog[%s] listen on port[%s]", watchdog, port)
end


-- GameUser相关的
function GateServer:onClientCmdLogin(data, socketfd)
	Log.d(TAG, "onClientCmdLogin uid[%s], socketfd[%s]", data.iUserId, socketfd)

end


return GateServer