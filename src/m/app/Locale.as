package m.app {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.filesystem.File;
	
	public class Locale {
		private var localePath:String;
		private var validLocals:Array
		private var actualLocale:String;
		
		private var translationTables:Object = new Object();
		
		public function Locale(localePath:String, validLocals:Array, defaultLocale:String) {
			this.localePath = localePath;
			this.validLocals = validLocals;
			this.actualLocale = defaultLocale;
			
			loadLocale(defaultLocale);
		}
		
		public function translate(key:String, locale:String = null):String {
			if (locale == null 
			|| !isValidLocale(locale))
				locale = actualLocale;
				
			if (translationTables[locale].hasOwnProperty(key))
				return translationTables[locale][key];
				
			return key;
		}
		
		public function isValidLocale(locale:String):Boolean {
			return validLocals.indexOf(locale) != -1;
		}
		
		private var onLocaleLoded:Function = null;
		public function loadLocale(locale:String, callback:Function = null):Boolean {
			if (!isValidLocale(locale))
				return false;
				
			actualLocale = locale;
			if (translationTables.hasOwnProperty(locale)){
				callback(this);
				return true;
			}
			
			translationTables[locale] = new Object();
			onLocaleLoded = callback;
			
			var path:String = this.localePath + locale + '.xml';
			
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, localeDefinitionLoaded);
			xmlLoader.load(new URLRequest(File.applicationDirectory.resolvePath(path).url));
			return true;
		}
		
		private function localeDefinitionLoaded(e:Event):void {
			XML.ignoreWhitespace = true;
			var translation:XML = new XML(e.target.data);
			
			var i:Number;
			for (i = 0; i < translation.lvar.length(); i++) 
				translationTables[actualLocale][translation.lvar[i].@id] = translation.lvar[i].text();
			
			if (onLocaleLoded != null)
				onLocaleLoded(this);
		}
	}
}