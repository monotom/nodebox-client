package nodebox{
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	import flash.events.Event;
	import flash.filesystem.File;
	import m.app.AppBase;
	import m.app.AppEvent;
	import m.io.LocalFileManager;
	import nodebox.app.Config;
	import nodebox.app.Desktop;
	import nodebox.io.provider.AbstractProvider;
	import nodebox.io.provider.DropBox;
	import nodebox.io.provider.Nodebox;
	import nodebox.plugins.desktop.AbstractDesktopPlugin;
	import nodebox.plugins.desktop.DesktopItemHandler;
	import nodebox.plugins.desktop.ItemInfo;
	import nodebox.plugins.desktop.NativeOsExecutor;
	import nodebox.plugins.desktop.ViewStateHandler;
	import nodebox.plugins.PluginEvent;
	import spark.components.WindowedApplication;
	
	public class App extends AppBase {
		public static var instance:App = new App();
		protected var config:Object = {};
		
		public var desktop:Desktop;
		public function App() {
			super();
			config = Config;
		}
		
	//app state		
		private var actualState:int = 0;
		private static const APP_STATE_BOOTSTRAPPED:int = 1;
		private static const APP_STATE_WAITING_FOR_CONNECT:int = 2;
		private static const APP_STATE_CONNECTED:int = 3;
		
		private function setState(state:int):void {
			actualState = state;
		}
		
		private function getState():int {
			return actualState;
		}
		
		public function isConnected():Boolean {
			return getState() == APP_STATE_CONNECTED;
		}
		
		public function isCompleet():Boolean {
			return getState() == APP_STATE_BOOTSTRAPPED;
		}

	//login/logout
		public function login(provider:AbstractProvider, data:Object):void {
			dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_CONNECT));
			onLogin();
		}
		
		private function onLogin(e:Event = null):void {
			setState(APP_STATE_CONNECTED);
			dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_CONNECTED));
		}
		
		private function onLoginError(e:Event = null):void {
			setState(APP_STATE_CONNECTED);
			dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_CONNECT_ERROR));
		}
		
		public function logout():void {
			dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_DISCONNECT));
			setState(APP_STATE_WAITING_FOR_CONNECT);
			onLoggedOut();
		}
		
		public function onLoggedOut(e:Event = null):void {
			dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_DISCONNECTED));
			desktop = null;
			setState(APP_STATE_WAITING_FOR_CONNECT);
			}
		
		public function shoutdown():void {
			dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_SHOUTDOWN));
			window.close();
		}
		
	//bootstrap
		public var window:WindowedApplication;
		public function bootstrap(app:WindowedApplication):void {
			if (actualState >= APP_STATE_BOOTSTRAPPED) 
				return ;
			
			super.bootstrapBeforeConfigLoaded();
			window = app;
		}
		
		override protected function bootstrapAfterConfigLoaded():void {
			super.bootstrapAfterConfigLoaded();
			setState(APP_STATE_BOOTSTRAPPED);
			desktop = new Desktop();
			setupPlugins();
			setupDataProvider();
			dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_COMPLEETE));
			logger.info('Application Storage Directory: '+File.applicationStorageDirectory.nativePath);
			logger.info('Application Loaded');
		}
		
		override protected function setupLogger():void {
			super.setupLogger();
			logger.setCallBack(function(msg:String):void { dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_LOGGER, msg)); } );
			dispatcher.addEventListener(AppEvent.ON_APP_LOGGER, function(e:AppEvent):void { 
					window.status = e.data; 
					try{
						desktop.uiComponent.text.text = e.data + "\n"+desktop.uiComponent.text.text;
					}
					catch (e:Error) { }
			});
		}
		
		private function setupPlugins():void {
			registerDesktopPlugin(new ViewStateHandler());
			registerDesktopPlugin(new DesktopItemHandler());
			registerDesktopPlugin(new NativeOsExecutor());
			registerDesktopPlugin(new ItemInfo());
			
			//registerDesktopPlugin(new ImageViewer());
			//registerDesktopPlugin(new MediaPlayer());
			//registerDesktopPlugin(new TextViewer());
			//registerDesktopPlugin(new WebBrowser());
			//registerDesktopPlugin(new FileExplorer());
		}
		
		private function setupDataProvider():void {
			registerDataProvider(new DropBox());
			registerDataProvider(new Nodebox());
			
		}
		
		private var dataProviders:Object = new Object();
		private function registerDataProvider(provider:AbstractProvider):void {
			dataProviders[provider.getName()] = provider;
			dispatchEvent(new PluginEvent(PluginEvent.ON_PROVIDER_REGISTERED, provider));
		}
		
		private var desktopPlugins:Object = new Object();
		private function registerDesktopPlugin(plugin:AbstractDesktopPlugin):void {
			desktopPlugins[plugin.getName()] = plugin;
			for each(var eventMap:Object in plugin.getSupportedEvents())
				addEventListener(eventMap.name, eventMap.dispatcher);
		}
		
		public static function getConfig():Object {
			return App.instance.config;
		}
		
		public var dataProvider:AbstractProvider = null;
		public function selectDataProviderByName(name:String):void {
			var eventMap:Object;
			if (dataProvider != null) {
				for each(eventMap in dataProvider.getSupportedEvents())
					removeEventListener(eventMap.name, eventMap.dispatcher);
			}
			App.instance.logger.info('provider:'+name);
			
			dataProvider = dataProviders[name];
			for each(eventMap in dataProvider.getSupportedEvents())
				addEventListener(eventMap.name, eventMap.dispatcher);
		}
		
		public var _localFileManager:LocalFileManager = null;
		public function get localFileManager():LocalFileManager {
			if (_localFileManager == null)
				_localFileManager = new LocalFileManager(getConfig());
				
			return _localFileManager;
		}
	}
}