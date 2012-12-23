package nodebox.app {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	import flash.filesystem.File;
	import m.app.AppConfig;
	import nodebox.App;
	
	public class Config extends AppConfig{
		public static var configXml:File = File.applicationDirectory.resolvePath('config.xml');
		
		public static var updateUrl:String = 'http://nodebox.local/updater/update.xml';
		
		public static function get():XML {
			return config;
		}
		
		public static var itemTextColor:String 		= "dfdff3";
		public static var itemBgColor:String		= "7070ca";
		public static var itemBorderColor:String	= "232372";
		
		public static var server:String				= "localhost";
		public static var application:String		= "nodeBOX";
		
		public static function get localFileStore():String {
			return File.applicationStorageDirectory.nativePath+'/'+App.instance.dataProvider.getName();
		}
	}
}
