package nodebox.ui.windows {
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.utils.getQualifiedClassName;
	import m.app.AppConfig;
	import m.ui.ChildWindow;
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.LinkButton;
	import mx.core.IVisualElement;
	import nodebox.App;
	import nodebox.io.provider.ProviderInterface;
	import nodebox.plugins.PluginEvent;
	import spark.components.Button;
	import spark.components.ComboBox;
	import spark.components.Image;
	import spark.components.TextArea;
	import spark.events.IndexChangeEvent;
	
	/**
	 * This class extends the base window class and is used to display the login form. @see m.ui.ChildWindow
	 * 
	 * @author Tom Hanoldt
	 */
	public class LoginWindow extends ChildWindow {
		public var providerSelect:ComboBox = new ComboBox();
		[Bindable]
        public var availableProvider:ArrayCollection = new ArrayCollection();
		/** 
		 * Constructor. Registers a method for information about new added file hoster.
		 */
		public function LoginWindow() {
			super();
			App.instance.addEventListener(PluginEvent.ON_PROVIDER_REGISTER, registerProvider);
			width = 520;
			height = 270;
		}
		
		private var providerContent:VBox = new VBox();
		/** 
		 * This method overrides the parents createChildren method for extending the view.
		 */
		override protected function createChildren():void {
			super.createChildren();
			title = 'Nodebox-Client login form';
			
			closeButton.visible = false;
			minimizeButton.visible = false;
			resizeButton.visible = false;
			
			var providerRow:HBox = new HBox();
			
			//providerselectbox
			providerSelect.dataProvider = availableProvider;
			providerSelect.addEventListener(IndexChangeEvent.CHANGE, selectProvider)
			providerRow.addElement(providerSelect);
			
			//help link
			var help:LinkButton = new LinkButton();
			help.label = 'get help';
			help.useHandCursor = true;
			help.setStyle('color', '#0000ff');
			help.addEventListener(MouseEvent.CLICK, function(e:Event = null):void {
				navigateToURL(new URLRequest(AppConfig.xml.app.helpLink));
			});
			
			providerRow.addElement(help);
			
			var vBox:VBox = new VBox();
			vBox.setStyle('paddingLeft', '15');
			vBox.setStyle('paddingRight', '15');
			vBox.setStyle('paddingTop', '15');
			vBox.setStyle('paddingBottom', '15');
			vBox.verticalScrollPolicy = 'off';
			vBox.horizontalScrollPolicy = 'off';
			vBox.addElement(providerRow);
			
			//content for provider specific form elements
			vBox.addElement(providerContent);
			
			//submit button
			var doLoginBtn:Button = new Button();
			doLoginBtn.label = 'connect';
			doLoginBtn.addEventListener(MouseEvent.CLICK, onSubmit);
			vBox.addElement(doLoginBtn);
			
			addElement(vBox);
		}
		
		/** 
		 * This method is called when the connect button inside the login form is pressed and utilitzes the Application iinstance to connect with selected file hoster.
		 *
		 * @param e The event that triggered the execution of this method.
		 */
		private function onSubmit(e:Event = null):void {
			App.instance.dataProvider.onLogin(e);
		}
		
		/** 
		 * This method is called from the application if a new file hoster or also named data provider is registered.
		 * 
		 * @param e The Plugin event that triggered that method and holds a reference to a file hoster plugin.
		 */
		public function registerProvider(e:PluginEvent):void {
			var provider:ProviderInterface = ProviderInterface(e.data);
			
			availableProvider.addItem(provider.getName());

			providerSelect.callLater(function(e:Event = null):void {
				providerSelect.selectedItem = provider.getName();
				selectProvider();
			});
		}
		
		/** 
		 * This method is called when the user changed the provider he want to connect to.
		 * 
		 * @param e The event that triggered that method.
		 */
		public function selectProvider(e:Event = null):void {
			App.instance.selectDataProviderByName(providerSelect.selectedItem);
			buildLoginForm(App.instance.dataProvider);
		}
		
		/** 
		 * This method generates the login form with the data defined from a file hoster plugin.
		 * 
		 * @param provider The data provider implementation. @see nodebox.io.provider.ProviderInterface
		 */
		private function buildLoginForm(provider:ProviderInterface):void {
			providerContent.removeAllElements();
			
			var infoWrapper:HBox = new HBox();
			var leftRow:VBox = new VBox();
			var infoText:TextArea = new TextArea();
			
			for each(var item:* in provider.getLoginformFields()) {
				if (getQualifiedClassName(item) == 'Array') {
					var hBox:HBox = new HBox();
					for each(var subItem:IVisualElement in item)
						hBox.addElement(subItem);
					
					leftRow.addElement(hBox);
				}
				else
					leftRow.addElement(item);
			}
			
			var img:Image = provider.getImage();
			if (img != null) {
				img.x = 200;
				img.y = img.y +30;
				img.scaleMode = 'zoom';
				img.height = 50;
				leftRow.addElement(img);
			}
			
			infoText.text = provider.getInfo();
			infoText.width = 220;
			infoText.setStyle('textAlign', 'justify'); 
			infoText.setStyle('lineHeight', '20');
			infoText.setStyle('borderVisible', 'false');
			infoText.setStyle('fontStyle', 'italic');
			infoText.setStyle('color', '#aaaaaa');
			infoText.editable = false;
			
			infoWrapper.addElement(leftRow);
			infoWrapper.addElement(infoText);
			providerContent.addElement(infoWrapper);
		}
	}
}