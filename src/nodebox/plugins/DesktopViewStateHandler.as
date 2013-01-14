package nodebox.plugins {
	import m.app.AppEvent;
	import nodebox.ui.DesktopBackground;
	import nodebox.ui.windows.LoginWindow;
	import nodebox.App;
	/**
	 * This class swicthes the view between the login window and the connected desktop view in correlation to the app state.
	 * 
	 * @author Tom Hanoldt
	 */
	public class DesktopViewStateHandler implements PluginInterface {
		private var loginWindow:LoginWindow = new LoginWindow();
		
		/**
		 * Constructor.
		 */
		public function DesktopViewStateHandler() {
			loginWindow.width = 500;
			loginWindow.height = 250;
		}
		
		/** 
		 * Interface implementation for getting the plugin name.
		 * 
		 * @return The name of the plugin.
		 */
		public function getName():String {
			return 'DesktopViewStateHandler';
		}
		
		/** 
		 * Interface implementation. This method returns a event and dispatcher method map so the application can register the dispatcher for application events.
		 * 
		 * @return Array of objects. Each object has to keys. One key is 'name' which tells the event name for which the second key 'dispatcher' holds a method that will be executed if the event happens.
		 */
		public function getSupportedEvents():Array {
			return [ { name: AppEvent.ON_APP_COMPLEETE, dispatcher: displayLogin },
			         { name: AppEvent.ON_APP_DISCONNECT, dispatcher: displayLogin },
			         { name: AppEvent.ON_APP_DISCONNECTED, dispatcher: displayLogin },
			         { name: AppEvent.ON_APP_CONNECTED, dispatcher: displayDesktop}];
		}
		
		/**
		 * This method displays the login window.
		 * 
		 * @param	e The event that triggered the execution of thid method.
		 */
		private function displayLogin(e:AppEvent = null):void {
			if(App.instance.window.contains(App.instance.desktop.uiComponent))
				App.instance.window.removeElement(App.instance.desktop.uiComponent);
			
			loginWindow.show();
		}
		
		/**
		 * This method hides the login windows and displays the desktop background.
		 * 
		 * @param	e The event that triggered the execution of thid method.
		 */
		private function displayDesktop(e:AppEvent = null):void {
			loginWindow.close();
			
			if(!App.instance.window.contains(App.instance.desktop.uiComponent))
				App.instance.window.addElement(App.instance.desktop.uiComponent);
		}
	}
}

