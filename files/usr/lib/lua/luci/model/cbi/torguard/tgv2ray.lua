-- TorGuard V2Ray Configuration
local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local fs = require("nixio.fs")
local json = require("luci.jsonc")

-- Create the model
m = Map("tgv2ray", "TorGuard V2Ray", "Manage TorGuard V2Ray connections using Sing-box")

-- Get current mode to determine if we should show proxy info
local current_mode = uci:get("tgv2ray", "settings", "mode") or "vpn"

-- Add proxy info box at the top if in proxy mode
if current_mode == "proxy" then
    local lan_ip = uci:get("network", "lan", "ipaddr") or "192.168.1.1"
    local socks_port = uci:get("tgv2ray", "settings", "local_port") or "1080"
    local http_port = uci:get("tgv2ray", "settings", "http_port") or "8080"
    
    m.description = [[
<div style="background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: 4px; padding: 12px; margin: 10px 0;">
    <strong>🌐 Proxy Connection Information:</strong><br>
    <br>
    <strong>SOCKS5 Proxy:</strong> ]] .. lan_ip .. [[:]] .. socks_port .. [[<br>
    <strong>HTTP Proxy:</strong> ]] .. lan_ip .. [[:]] .. http_port .. [[<br>
    <br>
    <em>Configure your browser or applications with one of the proxy addresses above.</em><br>
    <em>Use 127.0.0.1 instead of ]] .. lan_ip .. [[ when connecting from the router itself.</em>
</div>
]]
end

-- Main settings section
s = m:section(NamedSection, "settings", "tgv2ray", "V2Ray Settings")
s.addremove = false

-- Enable/Disable
enabled = s:option(Flag, "enabled", "Enable V2Ray")
enabled.default = "0"
enabled.rmempty = false

-- UUID
uuid = s:option(Value, "uuid", "UUID")
uuid.password = true
uuid.placeholder = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
uuid.description = 'Find your TorGuard UUID in the <a href="https://torguard.net/proxynetwork/vmess.php" target="_blank">members area</a>'

-- Mode
mode = s:option(ListValue, "mode", "Mode")
mode:value("vpn", "VPN (All Traffic)")
mode:value("proxy", "Proxy (SOCKS5/HTTP)")
mode.default = "vpn"



-- Server dropdown - dynamically populated
server = s:option(ListValue, "server", "Server")
server.placeholder = "Select a server"

-- Populate server list from servers.json
local servers_file = "/etc/tgv2ray/servers.json"
if fs.access(servers_file) then
    local servers_data = fs.readfile(servers_file)
    if servers_data then
        local servers = json.parse(servers_data)
        if servers then
            for _, srv in ipairs(servers) do
                server:value(srv.tag, srv.tag)
            end
        end
    end
end

-- If no servers loaded, show placeholder
if #server.keylist == 0 then
    server:value("", "No servers available - click Update Server List")
end

-- Local IP for VPN mode
local_ip = s:option(Value, "local_ip", "TUN IP")
local_ip.datatype = "ip4addr"
local_ip.default = "172.20.0.1"
local_ip:depends("mode", "vpn")
local_ip.description = "IP address for the VPN tunnel interface (TUN)"

-- Custom Server Import Section
-- Ensure custom section exists
if not uci:get("tgv2ray", "custom") then
    uci:section("tgv2ray", "server", "custom", {
        name = "Custom Server",
        link = "",
        enabled = "0"
    })
    uci:save("tgv2ray")
end

s2 = m:section(NamedSection, "custom", "server", "Custom Server Import")
s2.addremove = false
s2.anonymous = false

-- Custom server URL input
custom_url = s2:option(TextValue, "link", "Import Custom Server")
custom_url.description = "Paste a VLESS/VMess/Trojan/SS URL here and click Import"
custom_url.rows = 3
custom_url.wrap = "soft"

-- Service Control Section
s3 = m:section(NamedSection, "settings", "tgv2ray", "Service Control")
s3.addremove = false

-- Service status
status = s3:option(DummyValue, "_status", "Status")
status.template = "tgv2ray/status"

-- Buttons
buttons = s3:option(DummyValue, "_buttons", "")
buttons.template = "tgv2ray/buttons"

-- Update server list button
update = s3:option(Button, "_update", "")
update.title = "Update Server List"
update.inputtitle = "Update Server List"
update.inputstyle = "apply"

function update.write(self, section)
    luci.sys.call("/usr/bin/tgv2ray-subscription update >/dev/null 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "tgv2ray"))
end

-- Import custom server button
import = s3:option(Button, "_import", "")
import.title = "Import Custom Server"
import.inputtitle = "Import Server"
import.inputstyle = "add"

function import.write(self, section)
    local url = m:formvalue("cbid.tgv2ray.custom.link")
    if url and url ~= "" then
        -- Parse and add the custom server
        local result = luci.sys.exec("/usr/bin/tgv2ray-subscription parse '" .. url:gsub("'", "'\\''") .. "'")
        if result and result ~= "" then
            -- Append to servers.json
            local servers_data = fs.readfile(servers_file) or "[]"
            local servers = json.parse(servers_data) or {}
            local new_server = json.parse(result)
            if new_server then
                table.insert(servers, new_server)
                fs.writefile(servers_file, json.stringify(servers))
                -- Update UCI with new server
                uci:set("tgv2ray", "settings", "selected_server", new_server.tag)
                uci:commit("tgv2ray")
            end
        end
    end
    luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "tgv2ray"))
end

-- Start button
start = s3:option(Button, "_start", "")
start.title = "Click to Start V2Ray"
start.inputtitle = "Click to Start V2Ray"
start.inputstyle = "apply"

function start.write(self, section)
    luci.sys.call("/etc/init.d/tgv2ray start >/dev/null 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "tgv2ray"))
end

-- Stop button
stop = s3:option(Button, "_stop", "")
stop.title = "Click to Stop V2Ray"
stop.inputtitle = "Click to Stop V2Ray"
stop.inputstyle = "reset"

function stop.write(self, section)
    luci.sys.call("/etc/init.d/tgv2ray stop >/dev/null 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "tgv2ray"))
end

return m 