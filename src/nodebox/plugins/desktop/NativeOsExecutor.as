package nodebox.plugins.desktop {
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.ui.ContextMenuItem;
	import nodebox.App;
	import nodebox.plugins.PluginEvent;
	import nodebox.ui.DesktopItem;
	/**
	 * ...updateRemote create
	 * @author Tom Hanoldt
	 */
	public class NativeOsExecutor extends AbstractDesktopPlugin {
		public function NativeOsExecutor() {
			App.instance.dispatchEvent(new PluginEvent(PluginEvent.REGISTER_CONTEXT_MENU_HANDLER, create));
		}
		
		private function create(desktopItem:DesktopItem):Array {
			var contextMenuItem:ContextMenuItem = new ContextMenuItem('mit Standartanwendung öffnen')				
			contextMenuItem.addEventListener(Event.DISPLAYING, function(e:Event):void {
				contextMenuItem.enabled = desktopItem.item.isLocalAvailable();
				if (desktopItem.item.isDir)
					contextMenuItem.caption = 'Im Explorer Öffnen';
				else
				    contextMenuItem.caption = 'mit Standartanwendung öffnen';
			});
			
			contextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
				try{
					desktopItem.item.getLocalFile().openWithDefaultApplication();
				}
				catch (e:Error) {
					App.instance.logger.error(e.message);
				}
			});
			return [contextMenuItem];
		}
	}
}