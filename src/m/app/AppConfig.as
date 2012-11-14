package m.app {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	import flash.filesystem.File;
	import mx.controls.Image;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	 
	public class AppConfig {
		public static var configXml:File = File.applicationDirectory.resolvePath('config.xml');
		
//UPDATER		
		public static var updateUrl:String = 'http://nodebox.local/updater/update.xml';
		
//LOGGING
		public static var logErro:int = 1;//
		public static var logInfo:int = 8; //8
		public static var logWarning:int = 4;//4
		public static var logDebug:int = 16; //16
		public static var traceAll:int = 2; //2
		
//IMAGES
		public static var assetsPath:String = 'assets/'
	
//TRANSLATION
		public static var localePath:String = 'assets/locale/';
		public static var validLocals:Array = new Array('de');
		public static var defaultLocale:String = 'de';
		
		protected static var onConfigLoadedCallback:Function = null;
		public static function loadXml(path:String, callback:Function = null):void {
			onConfigLoadedCallback = callback;
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, configLoaded);
			xmlLoader.load(new URLRequest(File.applicationDirectory.resolvePath(path).url));
		}
		
		protected static var config:XML;
		protected static function configLoaded(e:Event):void {
			XML.ignoreWhitespace = true;
			config = new XML(e.target.data);
			
			updateUrl = config.app.update.url.text();
			
		//LOGGING
			if(config.app.log.logError.text() == '1')	logErro = 1;//
			if(config.app.log.logInfo.text() == '1')	logInfo = 8; //8
			if(config.app.log.logWarning.text() == '1')	logWarning = 4;//4
			if(config.app.log.logDebug.text() == '1')	logDebug = 16; //16
			if(config.app.log.traceAll.text() == '1')	traceAll = 2; //2
			
		//ASSETS
			assetsPath = config.app.assets.path.text();
		
		//TRANSLATION
			localePath = config.app.locale.path.text();
			validLocals= (''+config.app.locale.valid.text()).split(',');
			defaultLocale = config.app.locale.default.text();
			
			if (onConfigLoadedCallback != null)
				onConfigLoadedCallback();
		}
		
		public static function get():XML {
			return config;
		}
		
		public static function getString(section:String, key:String):String {
			return config[section][key].text(); 
		}
	}
}