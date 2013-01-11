package nodebox.app {
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import m.io.queue.FunctionQueue;
	import mx.events.DragEvent;
	import nodebox.App;
	import nodebox.io.IOEvent;
	import nodebox.io.Item;
	import nodebox.plugins.PluginEvent;
	import nodebox.ui.DesktopBackground;
	import nodebox.ui.DesktopItem;
	import nodebox.ui.UIEvent;
	/**
	 * This class handles the storage of the positioning for desktop items.
	 * 
	 * @author Tom Hanoldt
	 */
	public class DesktopConfig {
		public const CONFIG_ITEM_PATH:String = '.nbConfig.json';
		
		private var loading:Boolean = true;
		private var configItem:Item = null;
		private var configItemData:Object = { };
		
		/** 
		 * This method creates the configuration item where informations about the position of other desktop items is stored.
		 * 
		 * @param callback Called when the configuration item is created and stored local and remote.
		 */
		public function create(callback:Function = null):void {
			App.instance.logger.debug('DsektopConfig::create');
			configItem = new Item();
			configItem.path = CONFIG_ITEM_PATH;
			configItem.mimeType = 'json';
			configItem.writeJson(configItemData, function():void {
				loading = false;
				loadQueue.processQueue();
				if (callback != null)
					callback();
			});
		}
		
		/** 
		 * This method tests if a logical item on the desktop is the config item. This is done by testing the path of the item against '.nbConfig.json'
		 *
		 * @param item The item to test.
		 */
		public function isConfigItem(item:Item):Boolean {
			return item.path == CONFIG_ITEM_PATH;
		}
		
		/** 
		 * This method tells if a config item was found until now.
		 */
		public function hasConfigItem():Boolean {
			return configItem != null;
		}
		
		/** 
		 * This method sets the config item to store information about the position of desktop items.
		 * 
		 * @param item The config item for storing positions.
		 * @param callback A method that is executed if the the content of the item is stored 
		 *        locally and remote.
		 */
		public function setConfigItem(item:Item, callback:Function = null):void {
			App.instance.logger.debug('DsektopConfig::setConfigItem');
			
			configItem = item;
			configItem.getContentAsJson(function(data:Object):void {
				configItemData = data;
				loading = false;
				loadQueue.processQueue();
				if (callback != null)
					callback();
			});
		}
				
		/** 
		 * This method stores the data of the positions local and remote.
		 */
		public function save():void {
			if(!loading)
				configItem.writeJson(configItemData);
		}
		
		private var loadQueue:FunctionQueue = new FunctionQueue();
		/** 
		 * This method loads and sets the position of a desktop item. If the config item is not 
		 * vailable in this moment the operation is queued.
		 * 
		 * @param idesktopItem The desktop item the position should be loaded for.
		 * @param callback A method that is executed if the position is set. That could be 
		 *        later because of the queue.
		 */
		public function loadConfigForItem(desktopItem:DesktopItem, callback:Function = null):void {
			if (!loading) 
				return _loadConfigForItem(desktopItem);
			
			loadQueue.enqueue(function():void {
				_loadConfigForItem(desktopItem);
				loadQueue.queueCallback(callback);
			}, false);
		}
		
		/** 
		 * This method sets the position of a desktop item.
		 * 
		 * @param desktopItem The item for which the position should be set.
		 */
		private function _loadConfigForItem(desktopItem:DesktopItem):void {
			if (!configItemData.hasOwnProperty(desktopItem.item.path)) 
				return ;			
				
			desktopItem.x = configItemData[desktopItem.item.path].x;
			desktopItem.y = configItemData[desktopItem.item.path].y;
		}
		
		/** 
		 * This method applies the position to a set of items.
		 * 
		 * @param items An object containing the path of a item as key and the logical item as value.
		 */
		public function applyConfig(items:Object):void {
			for (var itemPath:String in configItemData)
				if (items.hasOwnProperty(itemPath))
					loadConfigForItem(items[itemPath]);
		}
				
		/** 
		 * This method stores the position of a desktop item and writes it back local and remote if needed and wanted.
		 * 
		 * @param desktopItem The desktop item to store the position for.
		 * @param storeIfNeeded Indicates if to update the local and remote storage with the new position.
		 */
		public function storeConfigForItem(destopItem:DesktopItem, storeIfNeeded:Boolean = true):void {
			App.instance.logger.debug('DsektopConfig::storeConfigForItem');
			
			var store:Boolean = false;
			var path:String = destopItem.item.path;
			if (configItemData.hasOwnProperty(path)
			&& configItemData[path].x != destopItem.x
			&& configItemData[path].y != destopItem.y)
				store = true;
			else
				configItemData[path] = { };

			configItemData[path].x = destopItem.x; 
			configItemData[path].y = destopItem.y; 

			if (storeIfNeeded
			&& store ) 
				save();
		}
	}
}