package nodebox.plugins {
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.ui.ContextMenuItem;
	import m.ui.Notice;
	import nodebox.App;
	import nodebox.io.Item;
	import nodebox.plugins.PluginEvent;
	import nodebox.ui.DesktopItem;
	import spark.components.TextArea;
	/**
	 * This class extends the application functionality by showing item details in a notice window.
	 * Also a second context menu entry will for syncing the item manually and deleting the item will be added to the desktop item context menu.
	 * 
	 * @author Tom Hanoldt
	 */
	public class DesktopItemContextMenu implements PluginInterface {
		/** 
		 * Constructor
		 */
		public function DesktopItemContextMenu() {
			App.instance.dispatchEvent(new PluginEvent(PluginEvent.REGISTER_CONTEXT_MENU_HANDLER_ITEM, create));
		}
		
		/** 
		 * Interface implementation for getting the plugin name.
		 * 
		 * @return The name of the plugin.
		 */
		public function getName():String {
			return 'DesktopItemInfo';
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
		 * This method creates the context menu entries.
		 */
		private function create(desktopItem:DesktopItem):Array {
			var window:Notice;
			
			var contextMenuItemDetails:ContextMenuItem = new ContextMenuItem("show details");				
			contextMenuItemDetails.addEventListener(Event.DISPLAYING, function(e:Event):void {
				if (!window){
					window = new Notice(250, 300);
					window.label.text = '' + desktopItem.item;
				}
			});
			
			contextMenuItemDetails.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
				window.show();
			});
			
			var contextMenuItemSync:ContextMenuItem = new ContextMenuItem("sync");				
			contextMenuItemSync.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
				desktopItem.item.sync();
			});
			
			var contextMenuItemDelete:ContextMenuItem = new ContextMenuItem("delete");				
			contextMenuItemDelete.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
				desktopItem.item.remove(function(item:Item):void {
					App.instance.logger.info('item deleted');
				});
			});	
			
			var contextMenuItemPush:ContextMenuItem = new ContextMenuItem("push file");				
			contextMenuItemPush.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
				desktopItem.item.updateRemote(function(item:Item):void {
					App.instance.logger.info('item uploaded');
				});
			})
			
			var contextMenuItemExecute:ContextMenuItem = new ContextMenuItem('open in native os');			
			contextMenuItemExecute.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
				try{
					desktopItem.item.getLocalFile().openWithDefaultApplication();
				}
				catch (e:Error) {
					App.instance.logger.error(e.message);
				}
			});
			
			var contextMenuItemCopyToClippoard:ContextMenuItem = new ContextMenuItem('copy to clippboard');			
			contextMenuItemCopyToClippoard.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
				desktopItem.item.copyToClipboard();
			});
			return [contextMenuItemDetails, contextMenuItemSync, contextMenuItemExecute, contextMenuItemCopyToClippoard, contextMenuItemPush, contextMenuItemDelete];
		}
	}
}