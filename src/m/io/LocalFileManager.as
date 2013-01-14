package m.io {
	import com.adobe.serialization.json.JSON;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	/**
	 * This class handles file system access.
	 * 
	 * @author Tom Hanoldt
	 */
	public class LocalFileManager {
		private var localStorageBase:String;
		/** 
		 * This method
		 * 
		 * @param localStorageBase the base path this instance operates on.
		 * 
		 * @return void
		 */
		public function LocalFileManager(localStorageBase:String) {
			this.localStorageBase = localStorageBase;
		}
		
		/** 
		 * This method builds a path relative to the base path.
		 * 
		 * @param path relative path
		 * 
		 * @return absolute path
		 */
		public function buildPath(path:String):String {
			return localStorageBase+'/'+path;
		}
		
		private var files:Object = {};
		/** 
		 * This method
		 * 
		 * @param e blalba
		 * 
		 * @return void
		 */
		public function getFile(path:String):File {
			if (typeof files[path] == 'undefined') {
				files[path] = new File(buildPath(path));
			}
			
			return files[path];
		}
		
		/** 
		 * This method returns a file reference inside the base path
		 * 
		 * @param path relative path
		 * 
		 * @return the file reference
		 */
		public function getFileRefference(path:String):FileReference {
			return getFile(path) as FileReference;
		}
		
		/** 
		 * This method cheks if a file exists.
		 * 
		 * @param path relative path
		 * 
		 * @return true if the file exists, false otherwise
		 */
		public function isAvailable(path:String):Boolean {
			return getFile(path).exists;
		}
		
		/** 
		 * This method creates a folder inside the base path
		 * 
		 * @param path relative path
		 * 
		 * @return void
		 */
		public function createFolder(path:String):void {
			getFile(path).createDirectory();
		}
		
		/** 
		 * This method creates a file by writing an empty string to the file
		 * 
		 * @param path relative path
		 * 
		 * @return void
		 */
		public function create(path:String):void {
			writeText(path, '');
		}
		
		/** 
		 * This method writes a text into a file
		 * 
		 * @param path relative path
		 * @param data text to be written
		 * 
		 * @return void
		 */
		public function writeText(path:String, data:String):void {
			write(path, function(fs:FileStream):void {
				fs.writeMultiByte(data, 'utf-8');
			});
		}
		
		/** 
		 * This method writes binary data to a file
		 * 
		 * @param path relative path
		 * @param data binary data
		 * 
		 * @return void
		 */
		public function writeBinary(path:String, data:ByteArray):void {
			write(path, function(fs:FileStream):void {
				fs.writeBytes(data);	
			});
		}
		
		/** 
		 * This method writes a objoct into a file
		 * 
		 * @param path relative path
		 * @param data the object to be written
		 * 
		 * @return void
		 */
		public function writeJson(path:String, data:Object):void {
			writeText(path, com.adobe.serialization.json.JSON.encode(data));
		}
		
		/** 
		 * This method
		 * 
		 * @param e blalba
		 * 
		 * @return void
		 */
		private function write(path:String, writeMethod:Function):void {
			var fs:FileStream = new FileStream();
            fs.open(getFile(path), FileMode.WRITE);
            writeMethod(fs) 
            fs.close();
		}
		
		/** 
		 * This method
		 * 
		 * @param e blalba
		 * 
		 * @return void
		 */
		private function read(path:String, readMethod:Function):void {
			var fs:FileStream = new FileStream();
            fs.open(getFile(path), FileMode.READ);
			readMethod(fs);
            fs.close();
		}
		
		/** 
		 * This method reads the content of a file and returns binary data
		 * 
		 * @param pathr elative path
		 * 
		 * @return void
		 */
		public function getContentAsBinary(path:String):ByteArray {
			var result:ByteArray = new ByteArray();
			read(path, function(fs:FileStream):void {
				fs.readBytes(result);
			});
			
			return result;
		}
		
		/** 
		 * This method reads the content of a file and returns text
		 * 
		 * @param path relative path
		 * 
		 * @return void
		 */
		public function getContentAsText(path:String):String {
			var result:String = '';
			read(path, function(fs:FileStream):void {
				result = fs.readMultiByte(fs.bytesAvailable, "utf-8");
			});
			return result;
		}
		
		/** 
		 * This method reads the content of a file and returns json decoded object
		 * 
		 * @param path relative path
		 * 
		 * @return void
		 */
		public function getContentAsJson(path:String):Object {
			return com.adobe.serialization.json.JSON.decode(getContentAsText(path));
		}
       
       /** 
		 * This method appends text to a text file
		 * 
		 * @param path relative path
		 * @param data text to append
		 * 
		 * @return void
		 */
		public function appendText(path:String,data:String):void{
            var fs:FileStream = new FileStream();
            fs.open(getFile(path), FileMode.APPEND);
            fs.writeMultiByte(data, 'utf-8');
            fs.close();
        }
		
          /** 
		 * This method updates a text file
		 * 
		 * @param path relative path
		 * @param data text to be written
		 * 
		 * @return void
		 */
		public function updateText(path:String, data:String, startIndex:int = 0):void{
            var fs:FileStream = new FileStream();
            fs.open(getFile(path), FileMode.UPDATE);
            fs.position = startIndex;
            fs.writeMultiByte(data, 'utf-8');
            fs.close();
        }
		
		/** 
		 * This method deletes a file
		 * 
		 * @param path relative path
		 * 
		 * @return void
		 */
		public function remove(path:String):void {
			try{
				if (getFile(path).isDirectory)
					getFile(path).deleteDirectory(true);
				else
					getFile(path).deleteFile();
			}catch (e:Error) {
			}
		}
		
		/** 
		 * This method returns the directory listening of the base path of this instance
		 * 
		 * @param ignoreFiles file names that should not be included
		 * 
		 * @return void
		 */
		public function getRootDirectoryListening(ignoreFiles:Array = null):Array {
			return getDirectoryListening('', ignoreFiles);
		}
		
		/** 
		 * This method returns the directory listening of folder
		 * 
		 * @param path relative path
		 * @param ignoreFiles file names that should not be included
		 * 
		 * @return void
		 */
		public function getDirectoryListening(path:String, ignoreFiles:Array = null):Array {
			var file:File = getFile(path);
			if (!file.exists || !file.isDirectory )
				return [];
			
			if(ignoreFiles == null)	
				return file.getDirectoryListing();
				
			var result:Array = [];
			for each(var subFile:File in file.getDirectoryListing()) {
				if (ignoreFiles.indexOf(subFile.name) == -1)
					result.push(subFile);
			}
			return result;
		}
    }
}