package m.app{
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;
	import flash.events.ErrorEvent;
	
	public class Updater {
		private var appOnError:Function;
		private var appOnUpdate:Function;
		private var url:String;
		private var updater:ApplicationUpdaterUI = new ApplicationUpdaterUI(); 
		
		public function Updater(url:String, appOnError:Function = null, appOnUpdate:Function = null) {
			//TODO start intervall for checking 
			this.appOnError = appOnError;
			this.appOnUpdate = appOnUpdate;
			this.url = url;
		}
		
		public function checkForUpdate():void { 		
			updater.updateURL = url; 
			
			updater.addEventListener(UpdateEvent.INITIALIZED, onUpdaterUpdate); 
			updater.addEventListener(ErrorEvent.ERROR, onUpdaterError); 
			
			//we can hide the dialog asking for permission for checking for a new update; 
			updater.isCheckForUpdateVisible = false; 
			
			//if isFileUpdateVisible is set to true, File Update, File No Update, 
			//and File Error dialog boxes will be displayed 
			updater.isFileUpdateVisible = false; 
			
			//if isInstallUpdateVisible is set to true, the dialog box for installing the update is visible 
			updater.isInstallUpdateVisible = false; 
			
			updater.initialize(); 
		} 
			
		private function onUpdaterUpdate(event:UpdateEvent):void { 
			updater.checkNow();
			if(appOnUpdate is Function)
				appOnUpdate(event);
		} 
		
		private function onUpdaterError(event:UpdateEvent):void { 
			if(appOnError is Function)
				appOnError(event);
		} 
	}
}