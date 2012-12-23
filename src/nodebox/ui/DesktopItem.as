package nodebox.ui {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import nodebox.App;
	import nodebox.app.Config;
	import nodebox.io.IOEvent;
	import nodebox.io.Item;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.events.*;
	import spark.components.BorderContainer;
	import spark.components.SkinnableContainer;
	
	/**
	 * This class represents the visualisation of the desktop element.
	 * 
	 */	
	public class DesktopItem extends SkinnableContainer{		
		public  var item:Item;		
		private var label:Label = new Label();			
		private var labelContainer:BorderContainer = new BorderContainer();

		public function DesktopItem(item:Item):void{
			this.item = item;
			setUpUi();
		}
		
		private function setUpUi():void {
			mouseChildren = false;
			
			label.text = item.name;
			addElement(labelContainer);
			labelContainer.addElement(label);
			
			setStateIcon();
			
			if (item.icon){
				var typeImg:Image = new Image();
				typeImg.y -= 33;
				typeImg.x -= 25;
				typeImg.alpha = 0.75;
				typeImg.source = item.icon;
				addElementAt(typeImg, 0);
			}
			
			labelContainer.minHeight = 10;
			labelContainer.minWidth  = 10;
			labelContainer.setStyle("borderColor", "#"+Config.itemBorderColor);
			labelContainer.setStyle("boarderVisible", "true");
			labelContainer.setStyle("boarderStyle", "solid");
			labelContainer.setStyle("boarderWeight", "4");			
			labelContainer.setStyle("backgroundColor", "#"+Config.itemBgColor);
			labelContainer.setStyle("cornerRadius", "3");
			labelContainer.alpha = 0.8;
			
			labelContainer.filters = [new GlowFilter( parseInt(Config.itemBorderColor, 16), 0.9, 8, 8, 2, 4, true)];
						
			label.setStyle("paddingLeft", 3);
			label.setStyle("paddingRight", 3);
			label.setStyle("paddingTop", 1);
			label.setStyle("paddingBottom", 0);						
			label.setStyle("color", "#"+Config.itemTextColor);
		}
		
		private var stateImg:Image;
		public function setStateIcon(state:int = -1 ):void {
			if(stateImg == null){
				stateImg = new Image();
				stateImg.y -= 8;
				stateImg.x -= 25;
				stateImg.alpha = 0.95;
				addElement(stateImg);
			}
			
			if (state == -1)
				state = item.state;
				
			switch(state) {
				case Item.ITEM_STATE_INITIALIZED:
				case Item.ITEM_STATE_UNINITIALIZED:
					stateImg.source = App.instance.assets.getImagePath('app/disconnected.png');
				break;
				case Item.ITEM_STATE_SYNCED:
					stateImg.source = App.instance.assets.getImagePath('app/synced.png');
				break;
				case Item.ITEM_STATE_LOCAL_CHANGED:
				case Item.ITEM_STATE_SYNCING:
					stateImg.source = App.instance.assets.getImagePath('app/syncing.png');
				break;
				case Item.ITEM_STATE_UNSYNCABLE:
					stateImg.source = App.instance.assets.getImagePath('app/unsycable.png');
				break;
			}
		}
	}
}