package nodebox.ui {
	
	import flash.events.Event;
	import m.app.AppEvent;
	import nodebox.App;
	import nodebox.io.provider.AbstractProvider;
	import nodebox.plugins.PluginEvent;
	import m.ui.ChildWindow;
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import spark.components.ComboBox;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class DebugWindow extends ChildWindow {
		public var userPwdForm:HBox;
		
		public function DebugWindow() {
			super();
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
			App.instance.selectDataProviderByName(provider.getName());
			//TODO does not work
			providerSelect.callLater(function(e:Event = null):void {
				providerSelect.selectedItem = providerSelect.dataProvider.getItemAt(0);
				userPwdForm.visible = provider.needsUserAndPass();
			});
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