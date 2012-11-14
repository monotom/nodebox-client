package m.app{
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	import flash.desktop.NativeApplication;
	import flash.events.EventDispatcher;
	import m.app.Assets;
	import m.app.AppConfig;
	import m.app.Locale;
	import m.app.Logger;
	import m.app.Updater;
	
	public class AppBase extends EventDispatcher{
		protected function bootstrapBeforeConfigLoaded():void {	
			setupApplication();
			setupEvents();
			setupConfig();
		}
		
		protected function bootstrapAfterConfigLoaded():void {
			setupLogger();			
			setupAssets();
			setupLocale();
			setupUpdater();
		}
		
		public static function getConfig():Object {
				return AppConfig;
		}
		
		protected function setupConfig():void {
			getConfig().loadXml(getConfig().configXml.url, bootstrapAfterConfigLoaded);
		}
		
		protected var updater:Updater;
		protected function setupUpdater():void {
			updater = new Updater(getConfig().updateUrl);
			logger.info('checing for update');
			updater.checkForUpdate();
		}
		
		public var logger:Logger;
		protected function setupLogger():void {
			logger = new Logger(getConfig().logDebug & getConfig().logErro & getConfig().logInfo & getConfig().logWarning & getConfig().traceAll);
		}
		
		public var locale:Locale;
		protected function setupLocale():void {
			locale = new Locale(getConfig().localePath, getConfig().validLocals, getConfig().defaultLocale);
		}
		
		public var assets:Assets;
		protected function setupAssets():void {
			assets = new Assets(getConfig().assetsPath);
		}
		
		public var dispatcher:EventDispatcher;
		protected function setupEvents():void {
			dispatcher = this;
		}

		protected var appXml:XML; 
		protected var appXmlNs:Namespace; 
		protected function setupApplication():void {
			appXml = NativeApplication.nativeApplication.applicationDescriptor; 
			appXmlNs = appXml.namespace();	
		}

		public function getVersion():String {
	       return appXml.appXmlNs::versionNumber[0];
		}
		
		public function getId():String {
	       return appXml.appXmlNs::id[0];
		}
		
		public function getName():String {
	       return appXml.appXmlNs::filename[0];
		}
	}
}