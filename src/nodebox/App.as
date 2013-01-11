package nodebox{
	/**
	 * This is the main application handler for the nodebox app.
	 * 
	 * @author Tom Hanoldt
	 */
	import flash.events.Event;
	import flash.filesystem.File;
	import m.app.AppBase;
	import m.app.AppConfig;
	import m.app.AppEvent;
	import m.io.LocalFileManager;
	import mx.core.FlexGlobals;
	import mx.styles.StyleManager;
	import nodebox.app.Desktop;
	import nodebox.io.provider.ProviderInterface;
	import nodebox.plugins.PluginEvent;
	import nodebox.plugins.PluginInterface;
	import nodebox.plugins.PluginLoader;
	import spark.components.WindowedApplication;
	
	public class App extends AppBase {
		public static var instance:App = new App();
		
		public var desktop:Desktop;
		
	//app state		
		private var actualState:int = 0;
		private static const APP_STATE_BOOTSTRAPPED:int = 1;
		private static const APP_STATE_WAITING_FOR_CONNECT:int = 2;
		private static const APP_STATE_CONNECTED:int = 3;
		
		/** 
		 * Set the actual app state. 
		 * 
		 * @param state The new application state. Possible values bootsrapped=1, disconnected=2, connected=3
		 * 
		 * @return void
		 */
		private function setState(state:int):void {
			actualState = state;
		}
		
		/** 
		 * Test if the application is actually connected to a file hoster.
		 */
		public function isConnected():Boolean {
			return actualState == APP_STATE_CONNECTED;
		}
		
		/** 
		 * Test if the appplication is bootsrapped. Means is compleetly initialized.
		 */
		public function isCompleet():Boolean {
			return actualState == APP_STATE_BOOTSTRAPPED;
		}

	//login/logout
		/** 
		 * Set up application events. 
		 */
		override protected function setupEvents():void {
			super.setupEvents();
			
			addEventListener(AppEvent.ON_APP_CONNECT, function(e:Event = null):void {
					logger.info('connecting');
			});
			
			addEventListener(AppEvent.ON_APP_CONNECTED, function(e:Event = null):void {
					setState(APP_STATE_CONNECTED);
			});
			
			addEventListener(AppEvent.ON_APP_DISCONNECT, function(e:Event = null):void {
					dispatchEvent(new AppEvent(AppEvent.ON_APP_DISCONNECTED));
					desktop.clean();
			});
			
			addEventListener(AppEvent.ON_APP_DISCONNECTED, function(e:Event = null):void {
					setState(APP_STATE_WAITING_FOR_CONNECT);
					logger.info('disconnected');
			});
			
			addEventListener(AppEvent.ON_APP_CONNECT_ERROR, function(e:Event = null):void {
					dispatchEvent(new AppEvent(AppEvent.ON_APP_DISCONNECTED));
			});
		}
		
		/** 
		 * Shoutdown the application and close the application window.
		 */
		public function shoutdown():void {
			dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_SHOUTDOWN));
			window.close();
		}
		
	//bootstrap
		public var window:WindowedApplication;
		/** 
		 * This method is called after the flex application is initalized and sets up the nodebox application.
		 */
		public function bootstrap(app:WindowedApplication):void {
			if (actualState >= APP_STATE_BOOTSTRAPPED) 
				return ;
			
			super.bootstrapBeforeConfigLoaded();
			window = app;
			desktop = new Desktop();
		}
		
		/** 
		 * This method is called after the config file is available.
		 */
		override protected function bootstrapAfterConfigLoaded():void {
			super.bootstrapAfterConfigLoaded();
			
			setState(APP_STATE_BOOTSTRAPPED); 
			setupPlugins();
			
			dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_COMPLEETE));
			logger.info('Application Loaded');
		}
		
		/** 
		 * This method sets up the logger and routs logging events to the nodebox 
		 * application debug window.
		 */
		override protected function setupLogger():void {
			super.setupLogger();
			
			logger.setCallBack(function(msg:String):void { 
				window.status = msg;
				dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_LOGGER, msg)); 
				if (msg.indexOf('ERROR:') != -1)
					dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_ERROR, msg)); 
			});
		}
		
		/** 
		 * This method sets up the nodebox application plugins and registers 
		 * available file hoster plugins.
		 */
		private function setupPlugins():void { 
			for each(var plugin:PluginInterface in PluginLoader.getPlugins())
				registerDesktopPlugin(plugin);
			
			for each(var provider:ProviderInterface in PluginLoader.getDataProvider())
				registerDataProvider(provider);
		}
		
		private var desktopPlugins:Object = new Object();
		/** 
		 * This method registers a desktop plugin and adds supportet events.
		 */
		private function registerDesktopPlugin(plugin:PluginInterface):void {
			desktopPlugins[plugin.getName()] = plugin;
			for each(var eventMap:Object in plugin.getSupportedEvents())
				addEventListener(eventMap.name, eventMap.dispatcher);
		}
		
		/** 
		 * This method unregisters a desktop plugin and removes supportet events.
		 */
		private function unregisterDesktopPlugin(plugin:PluginInterface):void {
			if (plugin != null
			&& desktopPlugins.hasOwnProperty(plugin.getName())) {
				for each(var eventMap:Object in plugin.getSupportedEvents())
					removeEventListener(eventMap.name, eventMap.dispatcher);
			}
		}
		
		private var dataProviders:Object = new Object();
		/** 
		 * This method registers a file hoster plugin and dispatches a related event.
		 */
		private function registerDataProvider(provider:ProviderInterface):void {
			dataProviders[provider.getName()] = provider;
			dispatchEvent(new PluginEvent(PluginEvent.ON_PROVIDER_REGISTER, provider));
		}

		private var _dataProvider:ProviderInterface = null;
		public function get dataProvider():ProviderInterface {
			return _dataProvider;
		}
		/** 
		 * This method selects a registered dataprovider to be used for the next steps.
		 */
		public function selectDataProviderByName(name:String):void {
			unregisterDesktopPlugin(_dataProvider);
			_dataProvider = dataProviders[name];
			registerDesktopPlugin(_dataProvider);
		}
		
		private var _localFileManager:LocalFileManager = null;
		/** 
		 * This method creates and returns the local file manager for accessing the local file system
		 * 
		 * @return The local file manager.
		 */
		public function get localFileManager():LocalFileManager {
			return new LocalFileManager(getLocalStorageLocation());
		}
		
		/** 
		 * This method builds the local filesystem storage path for the select file hoster and the account the user is logged in with.
		 * 
		 * @return The local storage path for the actual hoster and user.
		 */
		public function getLocalStorageLocation():String {
			return File.applicationStorageDirectory.nativePath+'/'+dataProvider.getName()+'/'+dataProvider.uniqueUserId();
		}
	}
}