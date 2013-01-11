package nodebox.plugins {
	import flash.events.Event;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import m.app.AppConfig;
	import m.app.AppEvent;
	import m.io.timer.PeriodicExecuter;
	import nodebox.App;
	import nodebox.app.LocalConfigItem;
	import nodebox.io.Item;
	
	/**
	 * This Plugin loads and refreshes the root items on the desktop if the application is connected .
	 * 
	 * @author Tom Hanoldt
	 */
	public class DesktopItemHandler implements PluginInterface {
		private var periodicExecuter:PeriodicExecuter;
		private var localConfig:LocalConfigItem;
		/** 
		 * Constructor.
		 */
		public function DesktopItemHandler() {
			periodicExecuter = new PeriodicExecuter(AppConfig.xml.app.syncRootFolderIntervallMs, executerCallback, false);
			registerClassAlias("Item", Item);  
		}
		
		/** 
		 * Interface implementation for getting the name og the plugin.
		 */
		public function getName():String {
			return 'DesktopItemHandler';
		}
		
		/** 
		 * Interface implementation. This method returns a event and dispatcher method map so the application can register the dispatcher for application events.
		 * 
		 * @return Array of objects. Each object has to keys. One key is 'name' which tells the event name for which the second key 'dispatcher' holds a method that will be executed if the event happens.
		 */
		public function getSupportedEvents():Array {
			return [ { name: AppEvent.ON_APP_DISCONNECT, dispatcher: resetItems },
			         { name: AppEvent.ON_APP_DISCONNECTED, dispatcher: resetItems },
			         { name: AppEvent.ON_APP_CONNECTED, dispatcher: loadRootItems }];
		}
		
		public const ROOT_PATH:String = '';
		
		private var rootItems:Object = {};
		/** 
		 * This method loads the root items from the selected data provider and adds the 
		 * items to the desktop. @see nodebox.app.Desktop
		 * 
		 * @param e The triggering event.
		 */
		private var stopped:Boolean = true;
		private var localConfigFile:String;
		private function loadRootItems(e:Event):void {
			resetItems();
			stopped = false;
			
			localConfigFile = '.'+App.instance.dataProvider.uniqueUserId()+'.DesktopItemHandler.conf';
			localConfig = new LocalConfigItem(localConfigFile);
			
			if (localConfig.exists) {
				var data:ByteArray = localConfig.loadByteArray();
				rootItems = data.readObject() as Object;
				
				App.instance.desktop.addRootItems(rootItems);
				periodicExecuter.start();	
			}
			else{
				App.instance.dataProvider.getMetadata(ROOT_PATH, function(item:Item):void {
					for (var childPath:String in item.childs) {
						rootItems[childPath] = item.childs[childPath];
						rootItems[childPath].sync();
					}
					App.instance.desktop.addRootItems(rootItems);
					periodicExecuter.start();
				});
			}
		}
		
		/** 
		 * This method is called periodically and watches the root desktop items for cchanges.
		 */
		private function executerCallback(e:Event):void {
			if (stopped)
				return ;
				
			//stop the executor while processing
			periodicExecuter.stop();
			
			App.instance.dataProvider.getMetadata(ROOT_PATH, function(rootItem:Item):void {
				App.instance.logger.debug('changed item check: processing');
				var pathCache:Array = [], item:Item ;
				for each(item in rootItem.childs) {	
					//used for deletion of unpresent items	
					pathCache.push(item.path);
					
					//if the item is new, add to desktop and sync
					if (!rootItems.hasOwnProperty(item.path)) {
						App.instance.logger.debug('add item:'+item.path);
						rootItems[item.path] = item;
						App.instance.desktop.addRootItem(item);	
					}
					
					//sync item
					rootItems[item.path].sync();
				}
				
				//delete not present items
				for each(item in rootItems)
					if (pathCache.indexOf(item.path) == -1) 
						delete rootItems[item.path];
				
				//write back the coonfig object
				var bytes:ByteArray = new ByteArray();
				bytes.writeObject(rootItems);
				localConfig.saveByteArray(bytes);
				
				//restart the executer
				periodicExecuter.start();
			});
		}
		
		/** 
		 * This method resets the root items.
		 */
		private function resetItems(e:Event = null):void {
			rootItems = { };
			periodicExecuter.stop();
			stopped = true;
		}
	}
}