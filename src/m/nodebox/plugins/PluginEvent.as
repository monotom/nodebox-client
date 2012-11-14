package m.nodebox.plugins {
	import flash.events.Event;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class PluginEvent extends Event{
		public static const ON_PROVIDER_REGISTERED:String 	= 'plugin.io.provider.registered';
		
		public var data:*;
		public function PluginEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			this.data = data;
		}
	}
}