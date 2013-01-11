package m.app {
	/**
	 * This class handles access to the application config and loading of a config file.
	 * 
	 * @author Tom Hanoldt
	 */
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class AppConfig {
		public static var configXml:File = File.applicationDirectory.resolvePath('config.xml');
			
	//LOGGING
		public static var logErro:int 		= 1; //1
		public static var logInfo:int 		= 0; //8
		public static var logWarning:int 	= 0; //4
		public static var logDebug:int 		= 0; //16
		public static var traceAll:int		= 0; //2
		
	//IMAGES
		public static var assetsPath:String = 'assets/'
	
		protected static var onConfigLoadedCallback:Function = null;
		/** 
		 * This method starts the loading of a config xml file
		 * 
		 * @param path Path to the config xml file.
		 * @param callback Method that is called after config file is loaded.
		 * 
		 * @return void
		 */
		public static function loadXml(path:String, callback:Function = null):void {
			onConfigLoadedCallback = callback;
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, configLoaded);
			xmlLoader.load(new URLRequest(File.applicationDirectory.resolvePath(path).url));
		}
		
		public static var xml:XML;
		/** 
		 * Internal callback after config xml file is loaded.
		 * 
		 * @param e The loaded event.
		 * 
		 * @return void
		 */
		protected static function configLoaded(e:Event):void {
			XML.ignoreWhitespace = true;
			xml = new XML(e.target.data);
						
			//LOGGING
				if(xml.app.log.logError.text() 	== '1')	logErro 	= 1; 	//1
				if(xml.app.log.logInfo.text() 	== '1')	logInfo 	= 8; 	//8
				if(xml.app.log.logWarning.text() == '1')logWarning 	= 4;	//4
				if(xml.app.log.logDebug.text() 	== '1')	logDebug 	= 16; 	//16
				if(xml.app.log.traceAll.text() 	== '1')	traceAll 	= 2;	//2
				
			//ASSETS
				assetsPath = xml.app.assets.path.text();
		
			if (onConfigLoadedCallback != null)
				onConfigLoadedCallback();
		}
	}
}