package nodebox.app {
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import m.io.LocalFileManager;
	/**
	 * This class handles the storage of the positioning for desktop items.
	 * 
	 * @author Tom Hanoldt
	 */
	public class LocalConfigItem {
		public var path:String;
		private var model:LocalFileManager;
		
		public function LocalConfigItem(path:String) {
			this.path = path;
			model = new LocalFileManager(File.applicationStorageDirectory.nativePath);
		}
		/** 
		 * This method creates the configuration item where informations about the position of other desktop items is stored.
		 * 
		 * @param callback Called when the configuration item is created and stored local and remote.
		 */
		public function saveByteArray(data:ByteArray):void {
			model.writeBinary(path, data);
		}
		
		/** 
		 * This method tests if a logical item on the desktop is the config item. This is done by testing the path of the item against '.nbConfig.json'
		 *
		 * @param item The item to test.
		 */
		public function loadByteArray():ByteArray {
			return model.getContentAsBinary(path);
		}
		
		public function get exists():Boolean {
			return model.isAvailable(path);
		}
	}
}