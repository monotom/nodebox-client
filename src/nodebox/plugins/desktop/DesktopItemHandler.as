package nodebox.plugins.desktop {
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.ui.ContextMenuItem;
	import m.app.AppEvent;
	import m.io.timer.PeriodicExecuter;
	import nodebox.App;
	import nodebox.io.IOEvent;
	import nodebox.io.Item;
	import nodebox.plugins.PluginEvent;
	import nodebox.ui.DesktopItem;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class DesktopItemHandler extends AbstractDesktopPlugin {
		private var periodicExecuter:PeriodicExecuter;
		public function DesktopItemHandler(){
			App.instance.dispatchEvent(new PluginEvent(PluginEvent.REGISTER_CONTEXT_MENU_HANDLER, createContextMenu));
			periodicExecuter = new PeriodicExecuter(10000, executerCallback, false);
		}
		
		override public function getSupportedEvents():Array {
			return [ { name: AppEvent.ON_APP_DISCONNECTED, dispatcher: resetItems },
			         { name: AppEvent.ON_APP_CONNECTED, dispatcher: loadRootItems }];
		}
		
		public const ROOT_PATH:String = '';
		
		private var rootItem:Item;
		private var rootItems:Object = {};
		private function loadRootItems(e:Event):void {
			resetItems();
			App.instance.dataProvider.getMetadata(ROOT_PATH, function(item:Item):void {
				App.instance.logger.info('root data loaded');
				rootItem = item;
				for (var index:String in item.childs){ 
					App.instance.logger.info('rootChild: '+item.childs[index].path);
					rootItems[item.childs[index].path] = item.childs[index];
				}
				App.instance.desktop.addRootItems(rootItems);
				for each(var anyRootItem:Item in rootItems) {
					App.instance.logger.debug('creating root item: '+anyRootItem.path);
					anyRootItem.sync(function (i:Item):void {
						i.dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCED, i));
					});
				}
				
				periodicExecuter.start();
			});
		}
		
		private var lastDeltaCursor:String = null;
		private function executerCallback(e:Event):void {
			periodicExecuter.stop();
			
			App.instance.dataProvider.getChanged(rootItem.path, function(items:Array, lastDeltaCursor:String):void {
				/*if (this.lastDeltaCursor == lastDeltaCursor) {
					App.instance.logger.info('changed item check: no change');
					periodicExecuter.start();
					return ;
				}*/
				App.instance.logger.info('changed item check: processing');
				this.lastDeltaCursor = lastDeltaCursor;
				
				var pathCache:Array = [], item:Item ;
				for each(item in items) {
					pathCache.push(item.path);
					if (!rootItems.hasOwnProperty(item.path)) {
						App.instance.logger.info('loading new item:'+item.path);
						rootItems[item.path] = item;
						App.instance.desktop.addRootItem(item);
						item.create(function (i:Item):void {
							i.dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCED, i));
						});
					}
					else if (rootItems[item.path].revision == item.revision) {
						//nothing todo
					}
					else if (!item.isDeleted) {
						App.instance.logger.warning(item.path+'-old:'+rootItems[item.path].revision+' old:'+item.revision);
					
						for (var k:String in item)
							rootItems[item.path][k] = item[k];
				
					
						item.loadRemoteChanges();
					}
					else if (item.isDeleted) {
						item.remove();
						delete rootItem[item.path];
					}
				}
				
				for each(item in rootItems)
					if (pathCache.indexOf(item.path) == -1){
						item.remove();
						delete rootItem[item.path];
					}
				
				periodicExecuter.start();
			}, lastDeltaCursor);
		}
		
		private function resetItems(e:Event=null):void {
			rootItem = null;
			rootItems = { };
			periodicExecuter.stop();
		}
		
		private function createContextMenu(desktopItem:DesktopItem):Array {
			var contextMenuItemSync:ContextMenuItem = new ContextMenuItem("Synchronisieren");				
			contextMenuItemSync.addEventListener(Event.DISPLAYING, function(e:Event):void {
				contextMenuItemSync.enabled = (!desktopItem.item.isLocalAvailable()
											 || desktopItem.item.state == Item.ITEM_STATE_LOCAL_CHANGED);
			});
			
			contextMenuItemSync.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
				desktopItem.item.create(function(item:Item):void {
					App.instance.logger.info('item synced');
				});
			});
			
			var contextMenuItemDelete:ContextMenuItem = new ContextMenuItem("Löschen");				
			contextMenuItemDelete.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
				desktopItem.item.remove(function(item:Item):void {
					App.instance.logger.info('item deleted');
					delete rootItem[item.path];
				});
			});
			
			return [contextMenuItemSync, contextMenuItemDelete];
		}
	}
}