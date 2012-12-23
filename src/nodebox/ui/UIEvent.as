package nodebox.ui {
	import flash.events.Event;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class UIEvent extends Event{
		public static const ON_ITEM_CREATE:String 			= 'ui.item.create';
		public static const ON_ITEM_MOVE:String 			= 'ui.item.move';
		public static const ON_ITEM_DELETE:String 			= 'ui.item.delete';
		public static const ON_ITEM_RENAME:String 			= 'ui.item.rename';
		
		public static const ON_ITEM_DOUBLE_CLICK:String 	= 'ui.item.doubleclick.left';
		public static const ON_ITEM_CLICK:String 			= 'ui.item.click.left';
		public static const ON_ITEM_RIGHT_CLICK:String 		= 'ui.item.click.right';
		
		public static const ON_ITEM_DROPIN:String 			= 'ui.item.dropout';
		public static const ON_ITEM_DROPOUT:String 			= 'ui.item.dropin';		
		
		public var item:DesktopItem;
		public function UIEvent(type:String, item:DesktopItem = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			this.item = item;
		}
	}
}