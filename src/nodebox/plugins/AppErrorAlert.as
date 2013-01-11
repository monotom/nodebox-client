package nodebox.plugins {
	import m.app.AppEvent;
	import m.ui.Notice;
	/**
	 * This class extends the application functionality by opening a notice window when an error is logged from the application.
	 * 
	 * @author Tom Hanoldt
	 */
	public class AppErrorAlert implements PluginInterface {		
		/** 
		 * Interface implementation for getting the plugin name.
		 * 
		 * @return The name of the plugin.
		 */
		public function getName():String {
			return 'DesktopErrorAlert';
		}
		
		private var errorAlert:Notice = new Notice();
		/** 
		 * Interface implementation. This method returns a event and dispatcher method map so the application can register the dispatcher for application events.
		 * 
		 * @return Array of objects. Each object has to keys. One key is 'name' which tells the event name for which the second key 'dispatcher' holds a method that will be executed if the event happens.
		 */
		public function getSupportedEvents():Array {
			return [ { name:AppEvent.ON_APP_ERROR, dispatcher: function(e:AppEvent):void {
					errorAlert.label.text = e.data;
					errorAlert.title = 'Error occurred'; 
					errorAlert.show(null, true, false);
				}}];
		}
	}
}