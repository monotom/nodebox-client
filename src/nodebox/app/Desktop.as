package nodebox.app {
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import mx.core.FlexGlobals;
	import mx.events.DragEvent;
	import nodebox.App;
	import nodebox.io.IOEvent;
	import nodebox.io.Item;
	import nodebox.plugins.PluginEvent;
	import nodebox.ui.DesktopBackground;
	import nodebox.ui.DesktopItem;
	import nodebox.ui.UIEvent;
	/**
	 * The Desktop class is the managed bridge between logical items and user interface items. 
	 * This class handles creation and deletion of user interface items and sets up the context menu handlers for a logical and display item.
	 
	 * @author Tom Hanoldt
	 */
	public class Desktop {
		public var uiComponent:DesktopBackground = new DesktopBackground();
		/** 
		 * Constructor.
		 */
		public function Desktop() {
			uiComponent.addEventListener(DragEvent.DRAG_EXIT, dragEndHandler);
			
			uiComponent.addEventListener(DragEvent.DRAG_ENTER, nativeDragEnterHandler);
			
			uiComponent.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragEnterHandler);
			uiComponent.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, nativeDragDropHandler);	
			
			App.instance.addEventListener(PluginEvent.REGISTER_CONTEXT_MENU_HANDLER_ITEM, registerContextMenuHandlerItem);
			App.instance.addEventListener(PluginEvent.REGISTER_CONTEXT_MENU_HANDLER_DESKTOP, registerContextMenuHandlerDesktop);
			
			App.instance.addEventListener(IOEvent.ON_FILE_DELETED, function(e:IOEvent):void {
				removeItem(e.item);
			});
		}
		
		private var config:DesktopConfig = new DesktopConfig();
		private var items:Object = {};
		/** 
		 * This method is called when the root items are available. there is also a config item for positioning contained in the root items.
		 * 
		 * @param items An object containing the root items.
		 */
		public function addRootItems(items:Object):void {
			for each(var item:Item in items)
				addRootItem(item);
			
			if (!config.hasConfigItem()) 
				config.create();
				
			App.instance.logger.info('root data loaded');
		}
		
		/** 
		 * This method adds one root item to the desktop.
		 * 
		 * @param item The root item to be added to the desktop.
		 */
		public function addRootItem(item:Item):void {
			App.instance.logger.debug('add root item: '+item.path);
			if (config.isConfigItem(item))
				config.setConfigItem(item);
			else 
				addItem(item);
		}
				
		/**
		 * This method transform a logical item to a desktop item and add the item to the user interface.
		 * 
		 * @param	item The item to be transformed and added.
		 */
		private function addItem(item:Item):void {
			addDesktopItem(new DesktopItem(item));
		}
		
		private var lastAddX:int = 50;
		private var lastAddY:int = 50;
		/** 
		 * This method sets up a desktop item. Means it tries to load the position config and adds user interface related event handlers to the item.
		 *
		 * @param desktopItem The desktop item that should be added.
		 */
		private function addDesktopItem(desktopItem:DesktopItem):void {
			if (items.hasOwnProperty(desktopItem.item.path))
				return ;
				
			items[desktopItem.item.path] = desktopItem;
			uiComponent.addElement(desktopItem);
			
			desktopItem.x = lastAddX + desktopItem.width;
			desktopItem.y = lastAddY + desktopItem.height;
			lastAddX = lastAddX + desktopItem.width;
			lastAddY =  lastAddY + desktopItem.height;
			
			config.loadConfigForItem(desktopItem);
			var mouseDownHandler:Function = function (e:MouseEvent):void{   			
				NativeDragManager.doDrag(desktopItem, 
					desktopItem.item.createClipboard(),
					null,
					new Point( -desktopItem.mouseX, -desktopItem.mouseY));
			}			
			desktopItem.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            desktopItem.item.addEventListener(IOEvent.ON_FILE_SYNCING, function(e:IOEvent):void{ desktopItem.setStateIcon(Item.ITEM_STATE_SYNCING)});
			desktopItem.item.addEventListener(IOEvent.ON_FILE_SYNCED, function(e:IOEvent):void { desktopItem.setStateIcon(Item.ITEM_STATE_SYNCED) } );
			desktopItem.contextMenu = getContextMenu(desktopItem);			
		}
				
		/** 
		 * This method removes a item from the desktop.
		 * 
		 * @param item The item that should be removed.
		 */
		public function removeItem(item:Item):void{
			if(!items.hasOwnProperty(item.path))
				return ;
						
			uiComponent.removeElement(items[item.path]);
			
			delete items[item.path];
		}	
		
		/** 
		 * This method sets up the NativeDragManager to handle a desktop item on drag start.
		 * 
		 * @param event The native drag event.
		 */
		private function nativeDragEnterHandler(event:Event):void{
			NativeDragManager.acceptDragDrop(uiComponent);
		}
		
		/** 
		 * This method is called when a drop finishes. If it is a drop in from outside the application a 
		 * file upload must be initialized
		 * 
		 * @param event The native drag event.
		 */
		private function nativeDragDropHandler(event:NativeDragEvent):void{		
			if(!event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))			
				return ;
			
			try{
				var dropfiles:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				
				if (dropfiles == null
				|| !dropfiles.length > 0)
					return ;	
					
				handleFileDropIn(dropfiles);
			}					
			catch(e:Error){
				App.instance.logger.error("ioerror:"+e.getStackTrace());
			}			
		}
		
		/** 
		 * This method is called when a drag is finished and stores the position of the desktop item to the desktop config.
		 *
		 * @param event The drag event.
		 */
		private function dragEndHandler(e:DragEvent):void {
			var item:DesktopItem = DesktopItem(e.dragInitiator);
			config.storeConfigForItem(item);
		}
		
		/** 
		 * This method handles the file upload if there where files dropped inside the 
		 * application and dispatches an user interface event UIEvent.ON_ITEM_CREATE.
		 *
		 * @param files A Array of file refferences dropped into the application. 
		 * @param path 
		 */
		public function handleFileDropIn(files:Array):void{	
			var item:Item;
			var desktopItem:DesktopItem;
			
			for each (var file:File in files) {
				item = new Item();
				item.path = file.name;
				item.isDir = file.isDirectory;
			
				if (!items.hasOwnProperty(item.path))
					desktopItem = new DesktopItem(item);
				else
					desktopItem = items[item.path];
				
				addDesktopItem(desktopItem);
				desktopItem.x = uiComponent.mouseX;
				desktopItem.y = uiComponent.mouseY;
				
				config.storeConfigForItem(desktopItem);
				
				if (!item.copyFrom(file)) //file exists local
					App.instance.logger.info('file allready exists: ' + file.name);
				else 
					App.instance.dispatchEvent(new UIEvent(UIEvent.ON_ITEM_CREATE, desktopItem));
			}			
		}
			
		private var registeredContextMenuHandlers:Array = [];
		/** 
		 * This method is called if a a plugin registers a context menu entry and saves the execution callback.
		 * 
		 * @param e The plugin event.
		 */
		private function registerContextMenuHandlerItem(e:PluginEvent):void {
			registeredContextMenuHandlers.push(e.data);
		}
		
		/** 
		 * This method is called if a a plugin registers a context menu entry on the desktop background and saves the execution callback.
		 * 
		 * @param e The plugin event.
		 */
		private function registerContextMenuHandlerDesktop(e:PluginEvent):void {
			for each(var item:ContextMenuItem in e.data()) {
				var contextMenuCustomItems:Array = FlexGlobals.topLevelApplication.contextMenu.customItems;
                contextMenuCustomItems.push(item);
			}
		}
		
		/** 
		 * This method builds the context menu for a desktop item based on the previus registered context menu handlers.
		 */
		private function getContextMenu(desktopItem:DesktopItem):ContextMenu {
			var contextMenu:ContextMenu = new ContextMenu();
			for each(var f:Function in registeredContextMenuHandlers){
				contextMenu.customItems = contextMenu.customItems.concat(
																	f(desktopItem));
			}
			return contextMenu;
		}
		
		/**
		 * Reset the Desktop
		 */
		public function clean(e:Event = null):void {
			uiComponent.removeAllElements();
			config = new DesktopConfig();
			items = {};
		}
	}
}