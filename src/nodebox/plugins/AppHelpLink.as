package nodebox.plugins {
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.ui.ContextMenuItem;
	import nodebox.App;
	import m.app.AppConfig;
	import nodebox.plugins.PluginEvent;
 
	/**
	 * This class extends the application functionality by adding a help link to the nodebox website to the context menu of the application background.
	 * 
	 * @author Tom Hanoldt
	 */
	public class AppHelpLink implements PluginInterface {
		/** 
		 * Constructor.
		 */
		public function AppHelpLink() {
			App.instance.dispatchEvent(new PluginEvent(PluginEvent.REGISTER_CONTEXT_MENU_HANDLER_DESKTOP, create));
		}
		
		/** 
		 * Interface implementation for getting the plugin name.
		 * 
		 * @return The name of the plugin.
		 */
		public function getName():String {
			return 'DesktopHelpLink';
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
			var contextMenuHelp:ContextMenuItem = new ContextMenuItem("get help");
			contextMenuHelp.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
					navigateToURL(new URLRequest(AppConfig.xml.app.helpLink));
				});
			return [contextMenuHelp];
		}
	}
}