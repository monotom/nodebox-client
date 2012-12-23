package nodebox.ui {
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import m.app.AppEvent;
	import mx.containers.VBox;
	import mx.core.IVisualElement;
	import nodebox.App;
	import nodebox.io.Item;
	import nodebox.io.provider.AbstractProvider;
	import nodebox.plugins.PluginEvent;
	import m.ui.ChildWindow;
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import spark.components.Button;
	import spark.components.ComboBox;
	import flash.utils.getQualifiedClassName;
	import spark.events.IndexChangeEvent;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class LoginWindow extends ChildWindow {
		public var providerSelect:ComboBox = new ComboBox();
		[Bindable]
        public var availableProvider:ArrayCollection = new ArrayCollection();
		public function LoginWindow() {
			super();
			App.instance.addEventListener(PluginEvent.ON_PROVIDER_REGISTERED, registerProvider);
			
		}
		
		private var providerContent:VBox = new VBox();
		override protected function createChildren():void {
			super.createChildren();
			title = 'nodeBOX-Client mit Datenanbieter verbinden';
			
			closeButton.visible = false;
			minimizeButton.visible = false;
			//resizeButton.visible = false;
			
			var vBox:VBox = new VBox();
			//providerselectbox
			providerSelect.dataProvider = availableProvider;
			providerSelect.addEventListener(IndexChangeEvent.CHANGE, selectProvider)
			vBox.addElement(providerSelect);
			
			//content for provider specific form elements
			vBox.addElement(providerContent);
			
			//submit button
			var doLoginBtn:Button = new Button();
			doLoginBtn.label = 'Verbinden';
			doLoginBtn.addEventListener(MouseEvent.CLICK, onSubmit);
			vBox.addElement(doLoginBtn);
			
			addElement(vBox);
		}
		
		private function onSubmit(e:Event = null):void {
			App.instance.dataProvider.onLogin(e);
		}
		
		public function registerProvider(e:PluginEvent):void {
			var provider:AbstractProvider = AbstractProvider(e.data);
			
			availableProvider.addItem(provider.getName());
			//App.instance.selectDataProviderByName(provider.getName());
			//selectProvider();
			//TODO does not work
			/*providerSelect.callLater(function(e:Event = null):void {
				providerSelect.selectedItem = providerSelect.dataProvider.getItemAt(0);
			});*/
		}
		
		public function selectProvider(e:Event = null):void {
			App.instance.selectDataProviderByName(providerSelect.selectedItem);
			buildLoginForm(App.instance.dataProvider.getLoginformFields());
		}
		
		private function buildLoginForm(items:Array):void {
			providerContent.removeAllElements();
			for each(var item:* in items) {
				if (getQualifiedClassName(item) == 'Array') {
					var hBox:HBox = new HBox();
					for each(var subItem:IVisualElement in item)
						hBox.addElement(subItem);
					
					providerContent.addElement(hBox);
				}
				else
					providerContent.addElement(item);
			}
		}
	}
}