package nodebox.plugins.desktop {
	import flash.display.NativeMenu;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.ui.ContextMenuItem;
	import nodebox.App;
	import nodebox.io.Item;
	import nodebox.plugins.PluginEvent;
	import nodebox.ui.DesktopItem;
	import m.ui.Notice;
	import mx.controls.FlexNativeMenu;
	import spark.components.TextArea;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class ItemInfo extends AbstractDesktopPlugin {
		public function ItemInfo() {
			App.instance.dispatchEvent(new PluginEvent(PluginEvent.REGISTER_CONTEXT_MENU_HANDLER, create));
		}
		
		private function create(desktopItem:DesktopItem):Array {
			var window:Notice;
			
			var contextMenuItemDetails:ContextMenuItem = new ContextMenuItem("Details ansehen");				
			contextMenuItemDetails.addEventListener(Event.DISPLAYING, function(e:Event):void {
				if (!window){
					window = new Notice();
					window.width = 250;
					window.height = 300;
					var l:TextArea = new TextArea();
					l.text = '' + desktopItem.item;
			                   
					window.addElement(l);
				}
			});
			
			contextMenuItemDetails.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
				window.show();
			});
			
			var contextMenuItemSync:ContextMenuItem = new ContextMenuItem("Synchronisieren");				
			contextMenuItemSync.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
				desktopItem.item.sync();
			});
			
			return [contextMenuItemDetails, contextMenuItemSync];
		}
	}
}