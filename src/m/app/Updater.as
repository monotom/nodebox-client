package m.app{
	/**
	 * This class handles the application updatesn and utilizes the ApplicationUpdaterUI. see http://help.adobe.com/de_DE/FlashPlatform/reference/actionscript/3/air/update/ApplicationUpdaterUI.html
	 * 
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
		
		/** 
		 * Constructor.
		 * 
		 * @param url The url where informaions about the newest application version can be retireved.
		 * @param onAppError A mehtod called, when there is an error while retriving application information.
		 * @param onAppupdate A mehtod called, wehen there is an update vailable for the application.
		 * 
		 * @return void
		 */
		public function Updater(url:String, appOnError:Function = null, appOnUpdate:Function = null) {
			this.appOnError = appOnError;
			this.appOnUpdate = appOnUpdate;
			this.url = url;
		}
		
		/** 
		 * Start checking for a new version.
		 */
		public function checkForUpdate():void { 		
			updater.updateURL = url; 
			
			updater.addEventListener(UpdateEvent.INITIALIZED, onUpdaterUpdate); 
			updater.addEventListener(ErrorEvent.ERROR, onUpdaterError); 
			
			//we can hide the dialog asking for permission for checking for a new update; 
			updater.isCheckForUpdateVisible = true; 
			
			//if isFileUpdateVisible is set to true, File Update, File No Update, 
			//and File Error dialog boxes will be displayed 
			updater.isFileUpdateVisible = true; 
			
			//if isInstallUpdateVisible is set to true, the dialog box for installing the update is visible 
			updater.isInstallUpdateVisible = true; 
			
			updater.initialize(); 
		} 
			
		/** 
		 * This method. is called when ther is an update available.
		 * 
		 * @param event The update event
		 * 
		 * @return void
		 */
		private function onUpdaterUpdate(event:UpdateEvent):void { 
			updater.checkNow();
			if(appOnUpdate is Function)
				appOnUpdate(event);
		} 
		
		/** 
		 * This method is called when ther is an error retrieving application informations.
		 * 
		 * @param event The error event.
		 * 
		 * @return void
		 */
		   private function onUpdaterError(event:UpdateEvent):void { 
			if(appOnError is Function)
				appOnError(event);
		} 
	}
}