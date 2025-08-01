module("luci.controller.admin.tgv2ray", package.seeall)

function index()
    entry({"admin", "vpn", "tgv2ray"}, cbi("torguard/tgv2ray"), _("TorGuard V2Ray"), 103)
    entry({"admin", "vpn", "tgv2ray", "status"}, call("status")).leaf = true
end

function status()
    local sys = require "luci.sys"
    local data = {}
    
    data.running = (sys.call("pidof sing-box >/dev/null") == 0)
    
    luci.http.prepare_content("application/json")
    luci.http.write_json(data)
end 