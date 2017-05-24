local skynet = require "skynet"
local socketManager = require("byprotobuf/socketManager")
local socketCmd = require("logic/common/socketCmd")
local queue = require("skynet.queue")

local cs = queue()

local TAG = "ClientAgent"

ClientAgent = class()

function ClientAgent:start(conf)
	Log.dump(TAG, conf)
	local fd   = conf.fd
	self.m_gate = conf.gate
	self.m_watchdog  = conf.watchdog
	self.m_socketfd = fd
	-- 通知gate  来自fd链接的网络消息直接转发  不再走watchdog
	local pRet = skynet.call(self.m_gate, "lua", "forward", self.m_socketfd)
end


function ClientAgent:onClientCmdLogin(data, socketfd)
	Log.d(TAG, "onClientCmdLogin uid[%s], socketfd[%s]", data.iUserId, socketfd)
end

-- decypt解密
function ClientAgent:receiveData(socketfd, cmd, buffer)
	Log.d(TAG,'recv socket data socketfd[%s] cmd[0x%x]', socketfd, cmd)
	if cmd and self.s_cmdFuncMap[cmd] then
		Log.d(TAG, "ClientAgent:receiveData socketfd=[%d], cmd=[0x%x]", socketfd, cmd)
		local data = socketManager.receive(cmd, buffer, false)
		return cs(self.s_cmdFuncMap[cmd], ClientAgent, data, socketfd)
	end
end

ClientAgent.s_cmdFuncMap = {
	[socketCmd.CLIENT_CMD_LOGIN] = ClientAgent.onClientCmdLogin,
}

function ClientAgent:disconnect()
	cs(function()
		self.m_socketfd = nil
		Log.d(TAG, "ClientAgent is disconnect")
		-- todo: do something before exit
		skynet.exit()
	end)
end

skynet.start(function()
	skynet.dispatch("lua", function(_, _, command, ...)
		local f = ClientAgent[command]
		-- skynet.ret(skynet.pack(f(...)))
		f(ClientAgent, ...)
	end)
end)
