package nodebox.plugins{
	import flash.events.Event;
	/**
	 * This class extends the flash.events.Event class for adding some plugin related event types and a custom data reference.
	 * @author Tom Hanoldt
	 */
	public class PluginEvent extends Event{
		public static const ON_PROVIDER_REGISTER :String 			= 'plugin.io.provider.register';
		
		public static const REGISTER_CONTEXT_MENU_HANDLER_ITEM :String 	= 'plugin.item.menu.context.register';
		
		public static const REGISTER_CONTEXT_MENU_HANDLER_DESKTOP :String 	= 'plugin.desktop.menu.context.register';
		
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
		public function PluginEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			this.data = data;
		}
	}
}