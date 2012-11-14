package m.nodebox.app {
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import m.nodebox.App;
	import m.nodebox.io.Item;
	import m.nodebox.ui.DesktopBackground;
	import m.nodebox.ui.DesktopItem;
	import m.nodebox.ui.UIEvent;
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class Desktop {
		public var uiComponent:DesktopBackground = new DesktopBackground();
		public function Desktop() {
			uiComponent.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
			uiComponent.addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
			
			uiComponent.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,onDragIn);
			uiComponent.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onDrop);	
			
			uiComponent.contextMenu = createContextMenu();
		}
		
		private var configItem:Item = null;
		private var items:Object = {};
		public function addRootItems(items:Object):void {
			for (var index:String in items) {
				var item:Item = items[index];
				if (item.path == '/.nbConfig.json')
					configItem = item;
				else {
					addItem(item);
				}
			}
			
			/*if (configItem == null) {
				configItem = new Item();
				configItem.path = '/.nbConfig.json';
				configItem.mimeType = 'json';
				//TODO
				/*configItem.createLocalAndRemote(function(e:Event) {
					
				});/
			}
			else if(!configItem.isLocalAvailable()) {
				configItem.makeLokalAvailable(function(e:Event):void {
					processConfig();
				});
			}
			else {
				processConfig();
			}*/
		}
		
		private function processConfig():void {
			configItem.getContentAsJson(function (data:Object):void {
				for (var itemConfig:Object in data.items) {
					if (typeof items[itemConfig.path] == 'undefined')
						continue;
						
					items[itemConfig.path].x = itemConfig.x;
					items[itemConfig.path].y = itemConfig.y;
				}
			});
		}
		
		private function addItem(item:Item):void {
			var desktopItem:DesktopItem = new DesktopItem(item);
			addDesktopItem(desktopItem);
		}
		
		private function addDesktopItem(desktopItem:DesktopItem):void {
			items[desktopItem.item.path] = desktopItem;
			uiComponent.addElement(desktopItem);
				
			desktopItem.addEventListener(MouseEvent.CLICK, onClick);					
			desktopItem.addEventListener(MouseEvent.RIGHT_MOUSE_UP, createContextMenu);					
			desktopItem.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);		
			desktopItem.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
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
		
		public function onClick(e:MouseEvent):void {
			var item:DesktopItem = DesktopItem(e.currentTarget);
			App.instance.dispatchEvent(new UIEvent(UIEvent.ON_ITEM_CLICK, item));
		}
		
		public function onDoubleClick(e:MouseEvent):void {
			var item:DesktopItem = DesktopItem(e.currentTarget);
			App.instance.dispatchEvent(new UIEvent(UIEvent.ON_ITEM_DOUBLE_CLICK, item));
		}	
		
		private function createContextMenu():ContextMenu{
			var editContextMenu:ContextMenu = new ContextMenu();
			
			/*var cutItem:ContextMenuItem = new ContextMenuItem("Create")
			cutItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, createContextMenu);
			editContextMenu.customItems.push(cutItem); //reihenfogle im Menu
			*/
			var pasteItem:ContextMenuItem = new ContextMenuItem("Paste")
				
			pasteItem.visible = true;
			pasteItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, doPasteCommand);
			editContextMenu.customItems.push(pasteItem);
			
			return editContextMenu;
		}
		
		private var copyDesktopElement:DesktopItem;
		private function doPasteCommand(event:ContextMenuEvent):void{
			const copyConstant:String="-Kopie(";
			const copySuffix:String=")";
			
			if(!copyDesktopElement)
				return ;
			
			var first:int		= copyDesktopElement.name.lastIndexOf(copyConstant);
			var last:int		= copyDesktopElement.name.lastIndexOf(copySuffix);
			var x:int = 1;
			
			if(first < 0){
				name = this.copyDesktopElement.name;
			}
			else{
				var copyPart:String = copyDesktopElement.name.slice(first, last);
				var name:String		= copyDesktopElement.name.slice(0, first);
				var zahl:String		= copyDesktopElement.name.slice(first+copyConstant.length, last);
				
				if(!name) name = "";
				x = int(zahl);
				if(x == 0) x=1;
			}
			
			do{
				copyPart = copyConstant + (x++) + copySuffix;
				copyDesktopElement.name = name + copyPart;
			}
			while(copyDesktopElement.name == true)
		
			addDesktopItem(copyDesktopElement);
		}
		
		private var oldMouseX:int = 0;
		private var oldMouseY:int = 0;
		private function dragEnterHandler(event:DragEvent):void {
			if (event.dragSource.hasFormat("DesktopElementView")){
				oldMouseX = uiComponent.mouseX;
				oldMouseY = uiComponent.mouseY;
				DragManager.acceptDragDrop(uiComponent);
			}
		}
		
		private function mouseDownHandler(e:MouseEvent):void{   			
			var ds:DragSource = new DragSource();
			ds.addData(this, "DesktopElementView");               
			
			DragManager.doDrag(e.currentTarget as IUIComponent, ds, e);
		}
		
		private function dragDropHandler(e:DragEvent):void {
			var item:DesktopItem = DesktopItem(e.dragInitiator);
			if(!item){
				return ;
			}	
			item.x = item.x + (e.localX - oldMouseX);
			item.y = item.y + (e.localY - oldMouseY);
			//TODO check write configItem
		}
		
		private function onDragIn(event:NativeDragEvent):void{
			NativeDragManager.acceptDragDrop(uiComponent);
		}
		
		private function onDrop(event:NativeDragEvent):void{		
			if(!event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)){				
				return ;
			}
			App.instance.logger.info("file drop in:"+event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT));
			
			try{
				var dropfiles:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				
				if(dropfiles == null)
					return ;
				
				App.instance.dispatchEvent(new UIEvent(UIEvent.ON_ITEM_CREATE));
				
				handleFileDropIn(dropfiles);				
			}					
			catch(e:Error){
				App.instance.logger.info("ioerror:"+e.getStackTrace());
				return ;	
			}			
		}
		
		public function handleFileDropIn(files:Array, recursiv:int=-1, path:String = ""):void{
			for each (var file:File in files){
				if (file.isDirectory){
					if(recursiv == -1 || recursiv > 0)
						handleFileDropIn(file.getDirectoryListing(), --recursiv, path);
				}
				else{
					var desktopItem:DesktopItem = new DesktopItem(new Item());
					
					if(path)
						path += "/";
					
					desktopItem.item.path = path+file.name;
					desktopItem.item.name = file.name;
					desktopItem.x = uiComponent.mouseX;
					desktopItem.y = uiComponent.mouseY;
					
					addDesktopItem(desktopItem);
					
					App.instance.dispatchEvent(new UIEvent(UIEvent.ON_ITEM_CREATE, desktopItem));
				}
			}			
		}
	}
}