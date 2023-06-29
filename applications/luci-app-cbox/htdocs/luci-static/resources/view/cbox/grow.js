'use strict';
'require view';
'require uci';
'require rpc';
'require form';
'require fs';

var callLeds = rpc.declare({
	object: 'luci',
	method: 'getLEDs',
	expect: { '': {} }
});

return view.extend({
	load: function() {
		return Promise.all([
			callLeds(),
			L.resolveDefault(fs.list('/www' + L.resource('view/cbox/led-trigger')), [])
		]).then(function(data) {
			var plugins = data[1];
			var tasks = [];

			for (var i = 0; i < plugins.length; i++) {
				var m = plugins[i].name.match(/^(.+)\.js$/);

				if (plugins[i].type != 'file' || m == null)
					continue;

				tasks.push(L.require('view.system.led-trigger.' + m[1]).then(L.bind(function(name){
					return L.resolveDefault(L.require('view.system.led-trigger.' + name)).then(function(form) {
						return {
							name: name,
							form: form,
						};
					});
				}, this, m[1])));
			}

			return Promise.all(tasks).then(function(plugins) {
				var value = {};
				value[0] = data[0];
				value[1] = plugins;
				return value;
			});
		});
	},

	render: function(data) {
		var m, s, o, triggers = [];
		var leds = data[0];
		var plugins = data[1];

		for (var k in leds)
			for (var i = 0; i < leds[k].triggers.length; i++)
				triggers[i] = leds[k].triggers[i];

		m = new form.Map('system',
			_('Grow Room Configuration'),
			_('Configure you Grow Room Settings and Smart-Devices to control the Enviroment'));

		s = m.section(form.GridSection, 'led', '');
		s.anonymous = true;
		s.addremove = true;
		s.sortable = true;
		s.addbtntitle = _('Add Grow Room');

		s.option(form.Value, 'name', _('Name'));

		o = s.option(form.ListValue, 'sysfs', _('Room Mode'));
		Object.keys(leds).sort().forEach(function(name) {
			o.value(name)
		});

		o = s.option(form.ListValue, 'trigger', _('Days Remaining'));
		for (var i = 0; i < plugins.length; i++) {
			var plugin = plugins[i];

			if ( plugin.form.kernel == false )
				o.value(plugin.name, plugin.form.trigger);
			else
				for (var k = 0; k < triggers.length; k++)
					if ( plugin.name == triggers[k] )
						o.value(plugin.name, plugin.form.trigger);
		}

		s.addModalOptions = function(s) {
			for (var i = 0; i < plugins.length; i++) {
				var plugin = plugins[i];
				plugin.form.addFormOptions(s);
			}

			var opts = s.getOption();

			var removeIfNoneActive = function(original_remove_fn, section_id) {
				var isAnyActive = false;

				for (var optname in opts) {
					if (opts[optname].ucioption != this.ucioption)
						continue;

					if (!opts[optname].isActive(section_id))
						continue;

					isAnyActive = true;
					break;
				}

				if (!isAnyActive)
					original_remove_fn.call(this, section_id);
			};

			for (var optname in opts) {
				if (!opts[optname].ucioption || optname == opts[optname].ucioption)
					continue;
				opts[optname].remove = removeIfNoneActive.bind(opts[optname], opts[optname].remove);
			}
		};

		return m.render();
	}
});
