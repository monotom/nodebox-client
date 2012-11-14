package m.nodebox.plugins.desktop {
	import m.app.AppEvent;
	import m.nodebox.ui.DesktopBackground;
	import m.nodebox.ui.LoginWindow;
	import m.nodebox.ui.components.LoginForm;
	import m.nodebox.App;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class ViewStateHandler extends AbstractDesktopPlugin {
		private var loginWindow:LoginWindow = new LoginForm();
		
		public function ViewStateHandler(){

		}
		
		override public function getSupportedEvents():Array {
			return [ { name: AppEvent.ON_APP_COMPLEETE, dispatcher: displayLogin },
			         { name: AppEvent.ON_APP_DISCONNECTED, dispatcher: displayLogin },
			         { name: AppEvent.ON_APP_CONNECTED, dispatcher: displayDesktop}];
		}
		
		private function displayLogin(e:AppEvent = null):void {
			if(App.instance.window.contains(App.instance.desktop.uiComponent))
				App.instance.window.removeElement(App.instance.desktop.uiComponent);
			
			loginWindow.show(App.instance.window);
		}
		
		private function displayDesktop(e:AppEvent = null):void {
			loginWindow.close();
			
			if(!App.instance.window.contains(App.instance.desktop.uiComponent))
				App.instance.window.addElement(App.instance.desktop.uiComponent);
		}
	}
}