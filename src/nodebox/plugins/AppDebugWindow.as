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
	 * This class adds a contex menu entry for the application bg so a debug window can be opened.
	 * Also the debug window is set up so the application log messages can appear.
	 * @author Tom Hanoldt
	 */
	public class AppDebugWindow implements PluginInterface {
		/** 
		 * Constructor.
		 */
		public function AppDebugWindow() {
			App.instance.dispatchEvent(new PluginEvent(PluginEvent.REGISTER_CONTEXT_MENU_HANDLER_DESKTOP, create));
		}
		
		/** 
		 * Interface implementation for getting the plugin name.
		 * 
		 * @return The name of the plugin.
		 */
		public function getName():String {
			return 'DesktopDebugWindow';
		}
		
		private var debugWindow:DebugWindow = new DebugWindow();
		/** 
		 * Interface implementation. This method returns a event and dispatcher method map so the application can register the dispatcher for application events.
		 * 
		 * @return Array of objects. Each object has to keys. One key is 'name' which tells the event name for which the second key 'dispatcher' holds a method that will be executed if the event happens.
		 */
		public function getSupportedEvents():Array {
			return [ { name:AppEvent.ON_APP_LOGGER, dispatcher: function(e:AppEvent):void {
					debugWindow.addMessage(e.data);
				}}];
		}
		
		/** 
		 * This method creates the context menu entry.
		 */
		private function create():Array {
			var contextMenuItemShowDebugWindow:ContextMenuItem = new ContextMenuItem("open debug window");				
			contextMenuItemShowDebugWindow.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
				debugWindow.show();
			});
			
			return [contextMenuItemShowDebugWindow];
		}
	}
}