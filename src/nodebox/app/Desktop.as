package nodebox.app {
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import mx.events.DragEvent;
	import nodebox.App;
	import nodebox.io.IOEvent;
	import nodebox.io.Item;
	import nodebox.plugins.PluginEvent;
	import nodebox.ui.DesktopBackground;
	import nodebox.ui.DesktopItem;
	import nodebox.ui.UIEvent;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class Desktop {
		public var uiComponent:DesktopBackground = new DesktopBackground();
		public function Desktop() {
			uiComponent.addEventListener(DragEvent.DRAG_EXIT, dragEndHandler);
			
			uiComponent.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragEnterHandler);
			uiComponent.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, nativeDragDropHandler);	
			
			App.instance.addEventListener(PluginEvent.REGISTER_CONTEXT_MENU_HANDLER, registerContextMenuHandler);
			App.instance.addEventListener(PluginEvent.UNREGISTER_CONTEXT_MENU_HANDLER, unregisterContextMenuHandler);
			
			App.instance.addEventListener(IOEvent.ON_FILE_DELETED, function(e:IOEvent):void {
				removeItem(e.item);
			});
		}
		
		private var configItem:Item = null;
		private var configItemData:Object = {};
		private var items:Object = {};
		public function addRootItems(items:Object):void {
			for each(var item:Item in items) {
				addRootItem(item);
			}
			
			if (configItem == null) {
				configItem = new Item();
				configItem.path = '.nbConfig.json';
				configItem.mimeType = 'json';
				configItem.writeJson(configItemData, function(item:Item):void {
					applyConfig();
				});
			}
		}
		
		public function addRootItem(item:Item):void {
				if (item.path == '.nbConfig.json'){
					configItem = item;
					configItem.getContentAsJson(function(data:Object):void {
						configItemData = data;
						applyConfig();
					});
				}
				else 
					addItem(item);
		}
		
		private function storeConfigRemote():void {
			configItem.writeJson(configItemData);
		}
		
		private function loadConfigForItem(desktopItem:DesktopItem):void {
			if (!configItemData.hasOwnProperty(desktopItem.item.path)) 
				return ;
				
			desktopItem.x = configItemData[desktopItem.item.path].x;
			desktopItem.y = configItemData[desktopItem.item.path].y;
		}
		
		private function applyConfig():void {
			for (var itemPath:String in configItemData)
				if (items.hasOwnProperty(itemPath))
					loadConfigForItem(items[itemPath]);
		}
		
		private function addItem(item:Item):void {
			addDesktopItem(new DesktopItem(item));
		}
		
		private function storeConfigForItem(destopItem:DesktopItem, storeIfNeeded:Boolean = true):void {
			var store:Boolean = false;
			var path:String = destopItem.item.path;
			if (configItemData.hasOwnProperty(destopItem.item.path)
			&& configItemData[path].x != destopItem.x
			&& configItemData[path].y != destopItem.y)
				store = true;
			else
				configItemData[path] = { };

			configItemData[path].x = destopItem.x; 
			configItemData[path].y = destopItem.y; 

			if (storeIfNeeded
			&& configItem != null
			&& store ) 
				storeConfigRemote();
		}
		
		private var lastAddX:int = 30;
		private var lastAddY:int = 30;
		private function addDesktopItem(desktopItem:DesktopItem):void {
			if (items.hasOwnProperty(desktopItem.item.path))
				return ;
				
			var item:Item = desktopItem.item;
			items[item.path] = desktopItem;
			
			uiComponent.addElement(desktopItem);
			
			loadConfigForItem(desktopItem);
			if (desktopItem.x == desktopItem.y == 0) {
				lastAddX = desktopItem.x = lastAddX + desktopItem.width;
				lastAddY = desktopItem.y = lastAddY + desktopItem.height;
			}
			storeConfigForItem(desktopItem);
			
			var mouseDownHandler:Function = function (e:MouseEvent):void{   			
				NativeDragManager.doDrag(desktopItem, 
					item.createClipboard(),
					null,
					new Point(-desktopItem.mouseX,-desktopItem.mouseY));
			}
			
			var onClick:Function = function (e:MouseEvent):void {
				var item:DesktopItem = DesktopItem(e.currentTarget);
				App.instance.dispatchEvent(new UIEvent(UIEvent.ON_ITEM_CLICK, item));
			};
			
			var onDoubleClick:Function = function (e:MouseEvent):void {
				var item:DesktopItem = DesktopItem(e.currentTarget);
				App.instance.dispatchEvent(new UIEvent(UIEvent.ON_ITEM_DOUBLE_CLICK, item));
			};
			
			desktopItem.addEventListener(MouseEvent.CLICK, onClick);					
			desktopItem.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);		
			desktopItem.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            item.addEventListener(IOEvent.ON_FILE_SYNCING, function(e:IOEvent):void{ desktopItem.setStateIcon(Item.ITEM_STATE_SYNCING)});
			item.addEventListener(IOEvent.ON_FILE_SYNCED, function(e:IOEvent):void { desktopItem.setStateIcon(Item.ITEM_STATE_SYNCED) } );
			
			desktopItem.contextMenu = getContextMenu(desktopItem);
		}
		
		public function hasItemWithName(name:String):Boolean {
			for (var key:String in items)
				if (key.indexOf(name) !== -1)
					return true;
					
			return false;
		}
		
		public function removeItem(item:Item):void{
			if(!items.hasOwnProperty(item.path))
				return ;
						
			uiComponent.removeElement(items[item.path]);
			
			delete items[item.path];
		}	
		
		private function dragEndHandler(e:DragEvent):void {
			var item:DesktopItem = DesktopItem(e.dragInitiator);
			storeConfigForItem(item);
		}
		
		private function nativeDragEnterHandler(event:NativeDragEvent):void{
			NativeDragManager.acceptDragDrop(uiComponent);
		}
		
		private function nativeDragDropHandler(event:NativeDragEvent):void{		
			if(!event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))			
				return ;
			
			App.instance.logger.info("file drop in:"+event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT));
			try{
				var dropfiles:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				
				if(dropfiles == null)
					return ;	
					
				handleFileDropIn(dropfiles);
			}					
			catch(e:Error){
				App.instance.logger.info("ioerror:"+e.getStackTrace());
			}			
		}
		
		public function handleFileDropIn(files:Array, recursiv:int=-1, path:String = ""):void{	
			var item:Item;
			var desktopItem:DesktopItem;
			
			for each (var file:File in files) {
				item = new Item();
				item.path = path.length < 1 ? file.name : path + '/' +file.name;
				item.isDir = file.isDirectory;
			
				if (!items.hasOwnProperty(item.path))
					desktopItem = new DesktopItem(item);
				else
					desktopItem = items[item.path];
				
				addDesktopItem(desktopItem);
				desktopItem.x = uiComponent.mouseX;
				desktopItem.y = uiComponent.mouseY;
				
				storeConfigForItem(desktopItem);
				
				if (!item.copyFrom(file)) //file exists local
					App.instance.logger.info('file allready exists: ' + path + file.name);
				else
					App.instance.dispatchEvent(new UIEvent(UIEvent.ON_ITEM_CREATE, desktopItem));
			}			
		}
			
		private var registeredContextMenuHandlers:Array = [];
		private function registerContextMenuHandler(e:PluginEvent):void {
			registeredContextMenuHandlers.push(e.data);
		}
		
		private function unregisterContextMenuHandler(e:PluginEvent):void {
			var f:Function = Function(e.data);
			delete registeredContextMenuHandlers[registeredContextMenuHandlers.indexOf(f)];
		}
		
		private function getContextMenu(desktopItem:DesktopItem):ContextMenu {
			var contextMenu:ContextMenu = new ContextMenu();
			for each(var f:Function in registeredContextMenuHandlers){
				contextMenu.customItems = contextMenu.customItems.concat(
																	f(desktopItem));
			}
			return contextMenu;
		}
	}
}