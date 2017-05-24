
local skynet = require "skynet"
local GateServer = require("logic/common/gateServer")

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		skynet.ret(skynet.pack(GateServer[command](GateServer,...)))
	end)
end)
