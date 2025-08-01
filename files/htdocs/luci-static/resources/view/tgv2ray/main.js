'use strict';
'require view';
'require form';
'require uci';
'require fs';
'require ui';

return view.extend({
    render: function() {
        var m, s, o;

        m = new form.Map('tgv2ray', _('TorGuard V2Ray'), _('Manage TorGuard V2Ray connections using Sing-box'));

        s = m.section(form.TypedSection, 'tgv2ray', _('General Settings'));
        s.anonymous = true;
        s.addremove = false;

        o = s.option(form.Flag, 'enabled', _('Enable'));
        o.default = '0';

        o = s.option(form.Value, 'uuid', _('UUID'));
        o.password = true;
        o.placeholder = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX';

        o = s.option(form.ListValue, 'mode', _('Mode'));
        o.value('vpn', _('VPN (All Traffic)'));
        o.value('proxy', _('Proxy (SOCKS5/HTTP)'));
        o.default = 'vpn';

        o = s.option(form.Value, 'server', _('Server'));
        o.placeholder = 'server-name';

        o = s.option(form.Value, 'local_ip', _('Local IP'));
        o.datatype = 'ip4addr';
        o.default = '192.168.6.191';

        o = s.option(form.Button, '_update', _('Update Server List'));
        o.inputstyle = 'apply';
        o.onclick = function() {
            return fs.exec('/usr/bin/tgv2ray-subscription', ['update'])
                .then(function(res) {
                    ui.addNotification(null, E('p', _('Server list updated')), 'info');
                })
                .catch(function(err) {
                    ui.addNotification(null, E('p', _('Failed to update server list')), 'danger');
                });
        };

        return m.render();
    }
}); 