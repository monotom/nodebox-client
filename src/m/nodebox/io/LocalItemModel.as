package m.nodebox.io {
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class LocalItemModel {
		private var config:Object;
		public function LocalItemModel(config:Object) {
			this.config = config;
		}
		
		public function buildPath(path:String):String {
			return path;
		}
		
		private var files:Object = {};
		public function getFile(path:String):File {
			if (typeof files[path] == 'undefined') {
				files[path] = new File(buildPath(path));
			}
			
			return files[path];
		}
		
		public function getFileRefference(path:String):FileReference {
			return getFile(path) as FileReference;
		}
		
		public function isAvailable(path:String):Boolean {
			return getFile(path).exists;
		}
		
		public function createFolder(path:String):void {
			getFile(path).createDirectory();
		}
		
		public function create(path:String):void {
			writeText(path, '');
		}
		
		public function writeText(path:String, data:String):void {
			write(path, function(fs:FileStream):void {
				fs.writeUTFBytes(data);	
			});
		}
		
		public function writeBinary(path:String, data:ByteArray):void {
			write(path, function(fs:FileStream):void {
				fs.writeBytes(data);	
			});
		}
		
		public function writeJson(path:String, data:Object):void {
			write(path, function(fs:FileStream):void {
				fs.writeObject(data);	
			});
		}
		
		private function write(path:String, writeMethod:Function):void {
			var fs:FileStream = new FileStream();
            fs.open(getFile(path), FileMode.WRITE);
            writeMethod(fs) 
            fs.close();
		}
		
		private function read(path:String, readMethod:Function):void {
			var fs:FileStream = new FileStream();
            fs.open(getFile(path), FileMode.READ);
			readMethod(fs);
            fs.close();
		}
		
		public function getContentAsBinary(path:String):ByteArray {
			var result:ByteArray;
			read(path, function(fs:FileStream):void {
				fs.readBytes(result, 0, fs.bytesAvailable);
			});
			return result;
		}
		
		public function getContentAsText(path:String):String {
			var result:String;
			read(path, function(fs:FileStream):void {
				result = fs.readUTFBytes(fs.bytesAvailable);
			});
			return result;
		}
		
		public function getContentAsJson(path:String):Object {
			var result:Object;
			read(path, function(fs:FileStream):void {
				result = fs.readObject();
			});
			return result;
		}
       
        public function appendText(path:String,data:String):void{
            var fs:FileStream = new FileStream();
            fs.open(getFile(path), FileMode.APPEND);
            fs.writeUTFBytes(data);
            fs.close();
        }
		
        public function updateText(path:String, data:String, startIndex:int = 0):void{
            var fs:FileStream = new FileStream();
            fs.open(getFile(path), FileMode.UPDATE);
            fs.position = startIndex;
            fs.writeUTFBytes(data);
            fs.close();
        }
		
		public function remove(path:String):void {
			if (getFile(path).isDirectory)
				getFile(path).deleteDirectory();
			else
				getFile(path).deleteFile();
		}
    }
}