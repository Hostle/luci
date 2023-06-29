'use strict';
'require view';
'require dom';
'require ui';
'require form';
'require rpc';

var formData = {
	username:{
		us1: null
	},
	password: {
		pw1: null,
		pw2: null
	}
};

var callSetPassword = rpc.declare({
	object: 'luci',
	method: 'setPassword',
	params: [ 'username', 'password' ],
	expect: { result: false }
});

var callConnectToApi = rpc.declare({
	object: 'cbox',
	method: 'connectToApi',
	params: [ 'username', 'password' ],
	expect: { result: false }
});

return view.extend({
	checkPassword: function(section_id, value) {
		var strength = document.querySelector('.cbi-value-description'),
		    strongRegex = new RegExp("^(?=.{8,})(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*\\W).*$", "g"),
		    mediumRegex = new RegExp("^(?=.{7,})(((?=.*[A-Z])(?=.*[a-z]))|((?=.*[A-Z])(?=.*[0-9]))|((?=.*[a-z])(?=.*[0-9]))).*$", "g"),
		    enoughRegex = new RegExp("(?=.{6,}).*", "g");

		if (strength && value.length) {
			if (false == enoughRegex.test(value))
				strength.innerHTML = '%s: <span style="color:red">%s</span>'.format(_('Password strength'), _('More Characters'));
			else if (strongRegex.test(value))
				strength.innerHTML = '%s: <span style="color:green">%s</span>'.format(_('Password strength'), _('Strong'));
			else if (mediumRegex.test(value))
				strength.innerHTML = '%s: <span style="color:orange">%s</span>'.format(_('Password strength'), _('Medium'));
			else
				strength.innerHTML = '%s: <span style="color:red">%s</span>'.format(_('Password strength'), _('Weak'));
		}

		return true;
	},

	render: function() {
		var m, s, o;

		m = new form.JSONMap(formData, _('API Login'), _('Login to the tp-link-cloud api'));
		m.readonly = !L.hasViewPermission();

		s = m.section(form.NamedSection, 'password', 'password');

		o = s.option(form.Value, 'us1', _('Username'));
		o.password = false;

		o = s.option(form.Value, 'pw1', _('Password'));
		o.password = true;
		o.validate = this.checkPassword;

		o = s.option(form.Value, 'pw2', _('Confirmation'), ' ');
		o.password = true;
		o.renderWidget = function(/* ... */) {
			var node = form.Value.prototype.renderWidget.apply(this, arguments);

			node.querySelector('input').addEventListener('keydown', function(ev) {
				if (ev.keyCode == 13 && !ev.currentTarget.classList.contains('cbi-input-invalid'))
					document.querySelector('.cbi-button-save').click();
			});

			return node;
			

		};

		s = m.section(form.NamedSection, 'password', 'password');
		o = s.option(form.Value, 'us2', _('Test Section'), ' ');
		o.password = false;

		return m.render();
	},

	handleSave: function() {
		var map = document.querySelector('.cbi-map');

		return dom.callClassMethod(map, 'save').then(function() {
			if (formData.password.pw1 == null || formData.password.pw1.length == 0)
				return;

			if (formData.password.pw1 != formData.password.pw2) {
				ui.addNotification(null, E('p', _('Given password confirmation did not match, password not changed!')), 'danger');
				return;
			}

			return callConnectToApi(formData.username.us1, formData.password.pw1).then(function(success) {
				if (success)
					ui.addNotification(null, E('h3', _('Connected to tp-link-cloud API.')), 'danger');
				else
					ui.addNotification(null, E('p', _('Failed to connect to tp-link-cloud API.')), 'danger');

				formData.username.us1 = null;
				formData.password.pw1 = null;
				formData.password.pw2 = null;

				dom.callClassMethod(map, 'render');
			});
		});
	},

	handleSaveApply: null,
	handleReset: null
});
