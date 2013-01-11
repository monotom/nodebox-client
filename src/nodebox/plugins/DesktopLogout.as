package nodebox.plugins {
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.ui.ContextMenuItem;
	import m.app.AppEvent;
	import nodebox.App;
	import nodebox.plugins.PluginEvent;
	import nodebox.ui.windows.DebugWindow;
	import nodebox.ui.DesktopItem;
	/**
	 * This class extends the application functionality with a logout context menu entry in the applications background context menu.
	 *
	 * @author Tom Hanoldt
	 */
	public class DesktopLogout implements PluginInterface {
		
		/** 
		 * Constructor
		 */
		public function DesktopLogout() {
			App.instance.dispatchEvent(new PluginEvent(PluginEvent.REGISTER_CONTEXT_MENU_HANDLER_DESKTOP, create));
		}
		
		/** 
		 * Interface implementation for getting the plugin name.
		 * 
		 * @return The name of the plugin.
		 */
		public function getName():String {
			return 'DesktopLogout';
		}
		
		/** 
		 * Interface implementation. This method returns a event and dispatcher method map so the application can register the dispatcher for application events.
		 * 
		 * @return Array of objects. Each object has to keys. One key is 'name' which tells the event name for which the second key 'dispatcher' holds a method that will be executed if the event happens.
		 */
		public function getSupportedEvents():Array {
			return [];
		}
		
		/** 
		 * This method creates the context menu entry.
		 */
		private function create():Array {
			var contextMenuLogout:ContextMenuItem = new ContextMenuItem("disconnect");	
			contextMenuLogout.addEventListener(Event.DISPLAYING, function(e:Event):void {
				contextMenuLogout.enabled = App.instance.isConnected();
			});
			
			contextMenuLogout.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
				App.instance.dispatchEvent(new AppEvent(AppEvent.ON_APP_DISCONNECT));
			});
			
			return [contextMenuLogout];
		}
	}
}