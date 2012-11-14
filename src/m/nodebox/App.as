package m.nodebox{
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	import flash.events.Event;
	import m.app.AppEvent;
	import m.app.AppBase;
	import m.nodebox.app.Desktop;
	import m.nodebox.io.provider.AbstractProvider;
	import m.nodebox.io.provider.DropBox;
	import m.nodebox.io.provider.NodeBox;
	import m.nodebox.plugins.desktop.AbstractDesktopPlugin;
	import m.nodebox.plugins.desktop.FileExplorer;
	import m.nodebox.plugins.desktop.ImageViewer;
	import m.nodebox.plugins.desktop.ItemHandler;
	import m.nodebox.plugins.desktop.MediaPlayer;
	import m.nodebox.plugins.desktop.NativeOsExecutor;
	import m.nodebox.plugins.desktop.ViewStateHandler;
	import m.nodebox.plugins.desktop.WebBrowser;
	import m.nodebox.plugins.PluginEvent;
	import m.nodebox.ui.viewer.TextViewer;
	import spark.components.WindowedApplication;
	import m.nodebox.app.Config;
	
	public class App extends AppBase {
		public static var instance:App = new App();
		
		public var desktop:Desktop;
		public function App() {
			super();
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
			setState(APP_STATE_WAITING_FOR_CONNECT);
			dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_DISCONNECTED));
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
			setupPlugins();
			setupDataProvider();
			desktop = new Desktop();
			dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_COMPLEETE));
			logger.info('Application Loaded');
		}
		
		override protected function setupLogger():void {
			super.setupLogger();
			logger.setCallBack(function(msg:String):void { dispatcher.dispatchEvent(new AppEvent(AppEvent.ON_APP_LOGGER, msg)); } );
			dispatcher.addEventListener(AppEvent.ON_APP_LOGGER, function(e:AppEvent):void { 
					window.status = e.data; 
					try{
						desktop.uiComponent.text.text = desktop.uiComponent.text.text+e.data + "\n";
					}
					catch (e:Error) {
						
					}
			});
		}
		
		private function setupPlugins():void {
			registerDesktopPlugin(new ViewStateHandler());
			registerDesktopPlugin(new ItemHandler());
			
			//registerDesktopPlugin(new ImageViewer());
			//registerDesktopPlugin(new MediaPlayer());
			//registerDesktopPlugin(new NativeOsExecutor());
			//registerDesktopPlugin(new TextViewer());
			//registerDesktopPlugin(new WebBrowser());
			//registerDesktopPlugin(new FileExplorer());
		}
		
		private function setupDataProvider():void {
			registerDataProvider(new NodeBox());
			registerDataProvider(new DropBox());
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
			return Config;
		}
		
		public var dataProvider:AbstractProvider = null;
		public function selectDataProviderByName(name:String):void {
			var eventMap:Object;
			if (dataProvider != null) {
				for each(eventMap in dataProvider.getSupportedEvents())
					removeEventListener(eventMap.name, eventMap.dispatcher);
			}
			
			dataProvider = dataProviders[name];
			for each(eventMap in dataProvider.getSupportedEvents())
				addEventListener(eventMap.name, eventMap.dispatcher);
		}
	}
}