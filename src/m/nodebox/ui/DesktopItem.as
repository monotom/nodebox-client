package m.nodebox.ui 
{
	/**
	 * ...
	 * @author Tom Hanoldt
	 */

	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.events.*;
	import flash.filesystem.File;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import m.nodebox.app.Config;
	import m.nodebox.io.Item;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.core.BitmapAsset;
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.events.*;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	import mx.managers.PopUpManager;

	import spark.components.BorderContainer;
	import spark.components.SkinnableContainer;
	import spark.primitives.BitmapImage;
	

	/**
	 * This class represents the visualisation of the desktop element.
	 * 
	 */	
	public class DesktopItem extends SkinnableContainer{		
		public var item:Item;
		
		private var label:Label = new Label();			
		private var labelContainer:BorderContainer = new BorderContainer();
		//private var deleteItemDialog:DeleteItemDialog;	
		//private var editItemDialog:CreateItemDialog;
		
		public function DesktopItem(item:Item):void{
			this.item = item;
			
			mouseChildren = false;
			
			contextMenu = createContextMenue();
			
			label.text = item.name;
			
			addElement(labelContainer);
			labelContainer.addElement(label);
			
			var img:Image = new Image();
			img.y -= 33;
			img.x -= 25;
			img.alpha = 0.7;
			
			if (item.icon){
				img.source = item.icon;
				addElementAt(img, 0);
			}
			
			labelContainer.minHeight = 10;
			labelContainer.minWidth  = 10;
			labelContainer.setStyle("borderColor", "#"+Config.itemBorderColor);
			labelContainer.setStyle("boarderVisible", "true");
			labelContainer.setStyle("boarderStyle", "solid");
			labelContainer.setStyle("boarderWeight", "4");			
			labelContainer.setStyle("backgroundColor", "#"+Config.itemBgColor);
			labelContainer.setStyle("cornerRadius", "3");
			labelContainer.alpha = 0.7;
			
			labelContainer.filters = [new GlowFilter( parseInt(Config.itemBorderColor, 16), 0.9, 8, 8, 2, 4, true)];
						
			label.setStyle("paddingLeft", 3);
			label.setStyle("paddingRight", 3);
			label.setStyle("paddingTop", 1);
			label.setStyle("paddingBottom", 0);						
			label.setStyle("color", "#"+Config.itemTextColor);
			
			
			/*BindingUtils.bindProperty(this.item.vo, "x", this, "x");
			BindingUtils.bindProperty(this, "x", this.item.vo, "x");
			
			BindingUtils.bindProperty(this.item.vo, "y", this, "y");
			BindingUtils.bindProperty(this, "y", this.item.vo, "y");
			
			BindingUtils.bindProperty(this.item.vo, "name", label, "text");
			BindingUtils.bindProperty(label, "text", this.item.vo, "name");*/
			
			addEventListener(MouseEvent.MOUSE_DOWN, prepareNativeDrop);
			
			//TODO make name editable
			//TODO contextmenu show proporties (name, size, remote/local, locked)
			//TODO contextmenu lock/unlock
		}
				
		/*/Nur bei update von Server
		public function update(item:DesktopItem):void{
			label.text = item.vo.name;
			x		= item.vo.x;
			y		= item.vo.y;
		}*/
		
		private function createContextMenue():ContextMenu{
			var editContextMenu:ContextMenu = new ContextMenu();
			
			/*var deleteItem:ContextMenuItem = new ContextMenuItem("Delete")
			deleteItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, showDeleteItemDialog);
			editContextMenu.customItems.push(deleteItem);
			*/
			var copyItem:ContextMenuItem = new ContextMenuItem("Copy")
			copyItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, doCopyCommand);            
			editContextMenu.customItems.push(copyItem);
			/*
			var editItem:ContextMenuItem = new ContextMenuItem("Edit")
			editItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, showEditItemDialog);            
			editContextMenu.customItems.push(editItem);
			*/
			var localCopyItem:ContextMenuItem;
			if(item.isLocalAvailable())
			{
				localCopyItem = new ContextMenuItem("Delete Local")
				localCopyItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, deleteLocal);            
				editContextMenu.customItems.push(localCopyItem);				
			}
			else
			{
				localCopyItem = new ContextMenuItem("Download Local")
				localCopyItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, downloadLocal);            
				editContextMenu.customItems.push(localCopyItem);
			}
			
			/*var lockItem:ContextMenuItem;
			if(item.isLocked())
			{
				lockItem = new ContextMenuItem("Unlock")
				lockItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, unlock);            
				editContextMenu.customItems.push(lockItem);				
			}
			else
			{
				lockItem = new ContextMenuItem("Lock")
				lockItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, lock);            
				editContextMenu.customItems.push(lockItem);
			}*/
			return editContextMenu;
		}
		
		private function showDeleteItemDialog(event:ContextMenuEvent):void{
			/*if(!deleteItemDialog)
				deleteItemDialog = new DeleteItemDialog(sharedDesktop, item);
			
			deleteItemDialog.x = stage.mouseX - 100;
			deleteItemDialog.y = stage.mouseY - 100;
			
			PopUpManager.addPopUp(deleteItemDialog, this, true);*/
		}
		
		private function showEditItemDialog(event:ContextMenuEvent):void{
			/*if(!editItemDialog)
				editItemDialog = new CreateItemDialog(sharedDesktop, item);
			
			editItemDialog.x = stage.mouseX - 100;
			editItemDialog.y = stage.mouseY - 100;
			
			PopUpManager.addPopUp(editItemDialog, this, true);*/
		}
		
		private function doCopyCommand(event:ContextMenuEvent):void{
			//sharedDesktop.copyitem = item.clone();
		}
		
		private function downloadLocal(event:ContextMenuEvent):void{
			//item.makeLocalAvailable(sharedDesktop.getDesktopName(), onLocalAvailable);
		}
		
		private function deleteLocal(event:ContextMenuEvent):void{
			//item.deleteLocalCopy();
			contextMenu = createContextMenue();
		}
		
		private function lock(event:ContextMenuEvent):void{
			//item.lock();
			contextMenu = createContextMenue();
		}
		
		private function unlock(event:ContextMenuEvent):void{
			//item.unlock();
			contextMenu = createContextMenue();
		}
		
		private function prepareNativeDrop(event:MouseEvent=null):void {
			if(!item.isLocalAvailable())
			{
				trace("no native drop, element not availeble("+item.name+")");
				return ;
			}
			else
				trace("prepareNativeDrop");
			
			var transferObject:Clipboard = createClipboard();
			
			NativeDragManager.doDrag(this, 
				transferObject,
				null,
				new Point(-mouseX,-mouseY));
		}
		
		public function createClipboard():Clipboard {				
			var transfer:Clipboard = new Clipboard();
			if(!item.isLocalAvailable())			
				return transfer;
						
			transfer.setData(ClipboardFormats.FILE_LIST_FORMAT, 
				new Array(item.getLocalFile()), 
				false); 
			
			return transfer; 
		}
		
		private function onLocalAvailable(event:Event):void{
			trace("onLocalAvailable");
			contextMenu = createContextMenue();
		}	
	}
}