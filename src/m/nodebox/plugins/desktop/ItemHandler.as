package m.nodebox.plugins.desktop {
	import flash.events.Event;
	import m.app.AppEvent;
	import m.nodebox.io.IOEvent;
	import m.nodebox.io.Item;
	import m.nodebox.ui.DesktopBackground;
	import m.nodebox.ui.LoginWindow;
	import m.nodebox.ui.components.LoginForm;
	import m.nodebox.App;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class ItemHandler extends AbstractDesktopPlugin {
		public function ItemHandler(){

		}
		
		override public function getSupportedEvents():Array {
			return [ { name: AppEvent.ON_APP_DISCONNECTED, dispatcher: cleanItems },
			         { name: AppEvent.ON_APP_CONNECTED, dispatcher: loadRootItems }];
		}
		
		private var rootItem:Item;
		private var rootItems:Object = {};
		private var allItems:Object = {};
		private function loadRootItems(e:Event):void {
			App.instance.dataProvider.getMetadata('', function(item:Item):void {
				App.instance.logger.info('root data loaded');
				rootItem = item;
				for (var index:String in item.childs) {
					var subItem:Item = item.childs[index];
					allItems[subItem.path] = subItem;
					rootItems[subItem.path] = subItem;
				}
				App.instance.desktop.addRootItems(rootItems);
			});
		}
		
		private function cleanItems(e:Event):void {
			rootItem = null;
			rootItems = {};
			allItems = {};
		}
	}
}