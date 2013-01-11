package m.app {
	import flash.events.Event;
	/**
	 * This class extends the flash.events.Event class and adds application relatet event types
	 * 
	 * @author Tom Hanoldt
	 */
	public class AppEvent extends Event{
		public static const ON_APP_COMPLEETE:String 	= 'app.compleete';
		public static const ON_APP_CONNECT:String 		= 'app.connect.connect';
		public static const ON_APP_CONNECTED:String 	= 'app.connect.connected';
		public static const ON_APP_CONNECT_ERROR:String = 'app.connect.error';
		public static const ON_APP_DISCONNECT:String 	= 'app.connect.disconnect';
		public static const ON_APP_DISCONNECTED:String 	= 'app.connect.disconnected';
		public static const ON_APP_ERROR:String 		= 'app.error';
		public static const ON_APP_SHOUTDOWN:String 	= 'app.shoutdown';
		public static const ON_APP_LOGGER:String 		= 'app.logger';
		
		public var data:*;
		/** 
		 * Constructor. Extends the Event object with a generic data property.
		 * 
		 * @param type The event type.
		 * @param data Generic data for use inside the application.
		 * @param bubbles Effects the mechanism the event is distributet.
		 * @param canelable Defines if the event can be canceled.
		 * 
		 * @return void
		 */
		public function AppEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			this.data = data;
		}
	}
}