package m.app{
	import flash.desktop.NativeApplication;
	import flash.events.EventDispatcher;
	import m.app.AppConfig;
	import m.app.Assets;
	import m.app.Logger;
	import m.app.Updater;
	
	/**
	 * This is a base class for flex air applications providing functionality for bootstrapping config, 
	 * logging, assets and the application updater.
	 * 
	 * @author Tom Hanoldt
	 */
	public class AppBase extends EventDispatcher{
		
		/** 
		 * This method is called before the config xml file is loaded, 
		 * so here are no dependencies to the config file.
		 */
		protected function bootstrapBeforeConfigLoaded():void {	
			setupApplication();
			setupEvents();
			setupConfig();
		}

		/** 
		 * This method is called after the xml config file is loaded.
		 */
		protected function bootstrapAfterConfigLoaded():void {
			setupLogger();			
			setupAssets();
			setupUpdater();
		}
		
		/** 
		 * This method starts the loading of the xml config file. @see AppConfig
		 */
		protected function setupConfig():void {
			AppConfig.loadXml(AppConfig.configXml.url, bootstrapAfterConfigLoaded);
		}
		
		protected var updater:Updater;
		/** 
		 * This method sets up the application updater
		 */
		protected function setupUpdater():void {
			updater = new Updater(AppConfig.xml.app.updater.url);
			logger.info('checking for update: '+AppConfig.xml.app.updater.url);
			updater.checkForUpdate();
		}
		
		public var logger:Logger;
		/** 
		 * This method sets up the application logger. @see Logger
		 */
		protected function setupLogger():void {
			logger = new Logger(AppConfig.logDebug & AppConfig.logErro & AppConfig.logInfo & AppConfig.logWarning & AppConfig.traceAll);
		}
				
		public var assets:Assets;
		/** 
		 * This method sets up the asset manager. @see Assets
		 */
		protected function setupAssets():void {
			assets = new Assets(AppConfig.xml.app.assets.path);
		}
		
		public var dispatcher:EventDispatcher;
		/** 
		 * This method sets up application events.
		 */
		protected function setupEvents():void {
			dispatcher = this;
		}

		protected var appXml:XML; 
		protected var appXmlNs:Namespace; 
		/** 
		 * This method sets up the accessing of the application descriptor.
		 */
		protected function setupApplication():void {
			appXml = NativeApplication.nativeApplication.applicationDescriptor; 
			appXmlNs = appXml.namespace();	
		}

		/** 
		 * This method returns the application version defined in the application descriptor.
		 * 
		 * @return String Application version.
		 */
		public function getVersion():String {
	       return appXml.appXmlNs::versionNumber[0];
		}
		
		/** 
		 * This method returns the application id defined in the application descriptor.
		 */
		public function getId():String {
	       return appXml.appXmlNs::id[0];
		}
		
		/** 
		 * This method returns the name of the application.
		 */
		public function getName():String {
	       return appXml.appXmlNs::filename[0];
		}
	}
}