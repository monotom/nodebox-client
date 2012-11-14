package m.nodebox.ui {
	
	import m.app.AppEvent;
	import m.nodebox.App;
	import m.nodebox.io.provider.AbstractProvider;
	import m.nodebox.plugins.PluginEvent;
	import m.ui.ChildWindow;
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import spark.components.ComboBox;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class LoginWindow extends ChildWindow {
		public var providerSelect:ComboBox = new ComboBox();
		public var userPwdForm:HBox;
		[Bindable]
        public var availableProvider:ArrayCollection = new ArrayCollection();
		public function LoginWindow() {
			super();
			App.instance.addEventListener(PluginEvent.ON_PROVIDER_REGISTERED, registerProvider);
		}
		
		override protected function createChildren():void {
			super.createChildren();
			title = 'nodeBOX-Client mit Datenanbieter verbinden';
			
			closeButton.setVisible(false);
			minimizeButton.visible = false;
			statusLabel.visible = false;
			resizeButton.visible = false;
		}
		
		public function createAccount():void {
			
		}
		
		public function registerProvider(e:PluginEvent):void {
			var provider:AbstractProvider = AbstractProvider(e.data);
			availableProvider.addItem(provider.getName());
			//TODO does not work
			providerSelect.selectedItem = providerSelect.dataProvider.getItemAt(0);
		}
		
		public function selectProvider(e:Event):void {
			App.instance.selectDataProviderByName(providerSelect.selectedItem);
			userPwdForm.visible = App.instance.dataProvider.needsUserAndPass();
		}
		
		public function login(name:String, password:String ):void {
			App.instance.dispatchEvent(new AppEvent(AppEvent.ON_APP_CONNECT, {name: name,password: password}));
		}
	}
}