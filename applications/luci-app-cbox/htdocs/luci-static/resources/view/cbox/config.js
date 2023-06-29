'use strict';
'require view';
'require form';
'require tools.widgets as widgets';

return view.extend({
	render: function() {
		var m, s, o;

		m = new form.Map('cbox');

		s = m.section(form.NamedSection, 'general', _('Cbox Configuration'));
		s.anonymous   = false;
		s.addremove   = false;
		
		o = s.option(form.ListValue, 'CB_MODEL', _('Model'), _('Select Cbox Model'));
		o.value('1', _('Cbox 1000'));
		o.value('2', _('Cbox 2000'));
		o.value('3', _('Cbox 3000'));
		o.value('4', _('Cbox Producer'));
		o.default = '1';

		o = s.option(form.ListValue, 'CB_MODE', _('Growth Stage'), _('Select Stage of Growth'));
		o.value('1', _('Seedling'));
		o.value('2', _('Vegetation'));
		o.value('3', _('Flower Stg 1'));
		o.value('4', _('Flower Stg 2'));

		s = m.section(form.NamedSection, 'water', _('Automatic Watering Options'));
		s.anonymous   = false;
		s.addremove   = false;

		o = s.option(form.Flag, 'AUTO_WATER', _('Automatic Watering'));
		o.default = true;

		s = m.section(form.NamedSection, 'temp', _('Temperature & Humidity Options'));
		s.anonymous   = false;
		s.addremove   = false;

		o = s.option(form.Value, 'TEMP_HIGH', _('Lights on Temp'), _('Target temperature while lights are on'));
		o.datatype = 'float';
		o.rempty = 'false';
		
		o = s.option(form.Value, 'TEMP_LOW', _('Lights off Temp'), _('Target temperature while lights are off'));
		o.datatype = 'float';
		
		o = s.option(form.Value, 'HUM_HIGH', _('Humidity Lights on'), _('Target humidity while lights are on'));
		o.datatype = 'float';
		
		o = s.option(form.Value, 'HUM_LOW', _('Humidity Lights off'), _('Target humidity while lights are off'));
		o.datatype = 'float';

		s = m.section(form.NamedSection, 'light', _('Lights On/Off Options'));
		s.anonymous   = false;
		s.addremove   = false;
		
		o = s.option(form.Value, 'LIGHT_ON', _('Lights On'), _('Time lights come on'));
		o.datatype = 'uinterger';
		
		o = s.option(form.Value, 'LIGHT_OFF', _('Lights Off'), _('Time light go out'));
		o.datatype = 'uinterger';

		s = m.section(form.NamedSection, 'socket', _('Diagnostics Server Options'));
		s.anonymous   = false;
		s.addremove   = false;
		
		o = s.option(form.Value, 'SCK_HOST', _('Server Ip'), _('Diagnostics Server IP'));
		o.datatype = 'ipaddr';
		
		o = s.option(form.Value, 'SCK_PORT', _('Server Port'), _('Diagnostics Server Port'));
		o.datatype = 'uinterger';

		return m.render();
	}
});