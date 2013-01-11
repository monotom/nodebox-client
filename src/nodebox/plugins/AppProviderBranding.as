package nodebox.plugins {
	import m.app.AppEvent;
	import nodebox.App;
	import spark.components.Image;
	/**
	 * This is a desktop plugin and shows a provider logo on the desktop background and the provider name to the application title if the user connects successful.
	 * @author Tom Hanoldt
	 */
	public class AppProviderBranding implements PluginInterface {
		/** 
		 * Interface implementation for getting the plugin name.
		 * 
		 * @return The name of the plugin.
		 */
		public function getName():String {
			return 'ConnectedProviderBranding';
		}
		
		private var img:Image = null;
		/** 
		 * Interface implementation. This method returns a event and dispatcher method map so the application can register the dispatcher for application events.
		 * 
		 * @return Array of objects. Each object has to keys. One key is 'name' which tells the event name for which the second key 'dispatcher' holds a method that will be executed if the event happens.
		 */
		public function getSupportedEvents():Array {
			return [ { name:AppEvent.ON_APP_CONNECTED, dispatcher: function(e:AppEvent):void {
						doDesktopBg();
						setTitle();
					 }},
					{ name:AppEvent.ON_APP_DISCONNECT, dispatcher: function(e:AppEvent):void {
						unsetTitle();
					}}
			];
		}
		
		/** 
		 * This method add the provider image to the desktop and removes the old one.
		 */
		private function doDesktopBg():void {
			if(img != null
			&& App.instance.desktop.uiComponent.contains(img))
				App.instance.desktop.uiComponent.removeElement(img);
				
			img = App.instance.dataProvider.getImage();
			if (img == null)
				return ;
				
			img.alpha = 0.5;
			img.x = 100;
			img.y = 100;
			App.instance.desktop.uiComponent.addElementAt(img, 0);
		}
		
		private var oldTitle:String = 'Nodebox-Client';
		/** 
		 * This method sets the application title and adds the provider name. 
		 */
		private function setTitle():void {
			if (oldTitle == null)
				oldTitle = App.instance.window.title;//doesnt work unreproducible times
				
			App.instance.window.title = oldTitle+'@'+App.instance.dataProvider.getName();
		}
		
		/** 
		 * This method resets the application title.
		 */
		private function unsetTitle():void {	
			App.instance.window.title = oldTitle;
		}
	}
}