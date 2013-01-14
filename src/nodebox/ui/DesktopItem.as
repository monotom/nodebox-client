package nodebox.ui {
	/**
	 * This class is used to display an io.Item on the desktop and wrapps the user interface logic arround the item. @see nodebox.io.Item
	 * 
	 * @author Tom Hanoldt
	 */
	import flash.display.Bitmap;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import m.app.AppConfig;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.events.*;
	import nodebox.App;
	import nodebox.io.Item;
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

		/** 
		 * Constructor.
		 * 
		 * @param item The item that is exposed to the user interface by this class.
		 */
		public function DesktopItem(item:Item):void{
			this.item = item;
			setUpUi();
		}
		
		/** 
		 * This method sets up the displayed item view.
		 */
		private function setUpUi():void {
			mouseChildren = false;
			
			label.text = item.name;
			addElement(labelContainer);
			labelContainer.addElement(label);
			
			setStateIcon();
			
			if (icon){
				var typeImg:Image = new Image();
				typeImg.y -= 33;
				typeImg.x -= 25;
				typeImg.alpha = 0.75;
				typeImg.source = icon;
				addElementAt(typeImg, 0);
			}
			
			labelContainer.minHeight = 10;
			labelContainer.minWidth  = 10;
			labelContainer.setStyle("borderColor", "#"+AppConfig.xml.app.colors.itemBorderColor);
			labelContainer.setStyle("boarderVisible", "true");
			labelContainer.setStyle("boarderStyle", "solid");
			labelContainer.setStyle("boarderWeight", "4");			
			labelContainer.setStyle("backgroundColor", "#"+AppConfig.xml.app.colors.itemBgColor);
			labelContainer.setStyle("cornerRadius", "3");
			labelContainer.alpha = 0.8;
			
			labelContainer.filters = [new GlowFilter( parseInt(AppConfig.xml.app.colors.itemBorderColor, 16), 0.9, 8, 8, 2, 4, true)];
						
			label.setStyle("paddingLeft", 3);
			label.setStyle("paddingRight", 3);
			label.setStyle("paddingTop", 1);
			label.setStyle("paddingBottom", 0);						
			label.setStyle("color", "#"+AppConfig.xml.app.colors.itemTextColor);
		}
		
		private var stateImg:Image;
		/** 
		 * This method sets the visual state for the item that is wrapped. 
		 *
		 * @param state The new item state. Possible states are Item.ITEM_STATE_INITIALIZED, Item.ITEM_STATE_UNINITIALIZED, Item.ITEM_STATE_SYNCED, Item.ITEM_STATE_LOCAL_CHANGED, Item.ITEM_STATE_SYNCING, Item.ITEM_STATE_UNSYNCABLE
		 */
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
					stateImg.source = App.instance.assets.getImagePath('app/unsyncable.png');
				break;
			}
		}
		
	    /** 
		 * This method tries to get an icon for the mime type of the wrapped icon. @see Assets
		 */
		public function get icon():Bitmap {
			return App.instance.assets.getImageFromExtension(item.extension);
		}
	}
}