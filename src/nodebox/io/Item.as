package nodebox.io{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import m.io.LocalFileManager;
	import nodebox.App;
	import nodebox.io.provider.AbstractProvider;
	/**
	 * either a dropbox file or a dropbox folder.
	 * 
	 * @author yinzeshuo
	 */
	public class Item extends EventDispatcher{
		public var bytes:Number;
		public var size:String;
		public var modified:Date;
		public var isDir:Boolean;
		public var root:String;
		public var mimeType:String;
		public var revision:String;
		public var isDeleted:Boolean;
		
		public var hash:String;
		public var childs:Object;
		
		public static const ITEM_STATE_UNINITIALIZED:int = 0;
		public static const ITEM_STATE_INITIALIZED:int = 1;
		public static const ITEM_STATE_SYNCED:int = 2;
		public static const ITEM_STATE_SYNCING:int = 3;
		public static const ITEM_STATE_UNSYNCABLE:int = 4;//TODO
		public static const ITEM_STATE_LOCAL_CHANGED:int = 5//TODO
		
		public var state:int = ITEM_STATE_UNINITIALIZED;
		
		public var remoteModel:AbstractProvider;
		public var localModel:LocalFileManager;
		private var self:Item;
		public function Item() {
			localModel = App.instance.localFileManager;
			remoteModel = App.instance.dataProvider;
			self = this;
		}
		
		public function get name():String {
			return path.split('/').pop();
		}
		
		public function set name(value:String):void {
			var tmp:Array = path.split('/');
			tmp.pop();
			path = tmp.join('/')+'/'+value;
		}
		
		public var _path:String;
		public function get path():String {
			return _path;
		}
		
		public static function normalizePath(path:String=null):String {
			return (path!=null &&path.charAt(0) == '/') ? path.substr(1) : path;
		}
		
		public static function setProperties(targetItem:Item, srcItem:Item):Item {
			targetItem.bytes	 = srcItem.bytes;
			targetItem.size		 = srcItem.size;
			targetItem.modified	 = srcItem.modified;
			targetItem.isDir	 = srcItem.isDir;
			targetItem.root		 = srcItem.root;
			targetItem.mimeType	 = srcItem.mimeType;
			targetItem.revision	 = srcItem.revision;
			targetItem.isDeleted = srcItem.isDeleted;
			targetItem.hash		 = srcItem.hash;
			for each(var subItem:Item in srcItem.childs) {
				if (!srcItem.childs.hasOwnProperty(subItem.path))
					srcItem.childs[subItem.path] = subItem;//TODO dispatch new event
				else
					Item.setProperties(srcItem.childs[subItem.path], subItem);
			}
			return targetItem;
		}
		
		public function set path(value:String):void {
			_path = normalizePath(value);
			if (localModel.isAvailable(_path))
				state = ITEM_STATE_SYNCED;
		}
		
		public function get pathWithoutName():String {	
			return path.substr(0, path.length - name.length);
		}
		
		public function get icon():Bitmap {
			return App.instance.assets.getImageFromExtension(extension);
		}
		
		public function get extension():String {
			return (name.indexOf('.') != -1) ? name.split('.').pop() : '';
		}
		
		public function getLocalFile():File {
			return localModel.getFile(path);
		}
		
		public function isLocalAvailable():Boolean {
			return localModel.isAvailable(path);
		}
		
		public function isRemoteAvailable(callback:Function):void {
			return remoteModel.isAvailable(path, callback);
		}
		
		public function loadRemoteChanges(callback:Function = null, overrideOnConflict:Boolean = true):void {
			localModel.remove(path);
			makeLokalAvailable(function (item:Item):void {
				Item.setProperties(self, item);
				callbackIfSet(callback, true);
			});
		}
		
		public function copyFrom(src:File):Boolean {
			App.instance.logger.info('Item.copyTo(from:' + src.nativePath + ',"to:' + localModel.getFile(path).nativePath + '")');
			try{
				src.copyTo(localModel.getFileRefference(path), false);
			}
			catch (e:Error) {
				return false;
			}
			state = ITEM_STATE_LOCAL_CHANGED;
			createRemote(function(item:Item):void {
				state = ITEM_STATE_SYNCED;
				dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCED, item));
				if (src.isDirectory) 
					createRecursiveRemote(src.getDirectoryListing(), path);
			});
			return true;
		}
		
		private function  createRecursiveRemote(files:Array, subPath:String = ''):void {
			var f:Function = function(subFile:File):void {
				var subItem:Item = new Item();
				subItem.path = subPath.length < 1 ? subFile.name : subPath + '/' +subFile.name;
				subItem.isDir = subFile.isDirectory;
				subItem.createRemote(function(subItem:Item):void {
					dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCED, subItem));
					if (subFile.isDirectory) 
						createRecursiveRemote(subFile.getDirectoryListing(), subItem.path);
				});	
			}
			for each(var subFile:File in files) 
				f(subFile);
		}
		
		public function makeLokalAvailable(callback:Function = null):void {
			var finish:Function = function():void {
				state = ITEM_STATE_SYNCED;
					if(callback != null)
						callback(self);
					dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCED, self));
			};
			App.instance.logger.info('Item.makeLokalAvailable("' + path + '"');
			if (isDir) {
				localModel.createFolder(path);
				finish();
			}
			else if (!isLocalAvailable()) {
				state = ITEM_STATE_SYNCING;
				dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCING, self));
				remoteModel.getFile(path, function(data:ByteArray):void {
					localModel.writeBinary(path, data);
					finish();
				});
			}
			else if(callback != null)
				callback(self);
		}
		
		public function updateRemote(callback:Function = null):void {
			App.instance.logger.info('Item.updateRemote(remotePath: ' + pathWithoutName + ' localPath:' + path);
			var file:File = localModel.getFile(path);
			remoteModel.uploadFile(pathWithoutName, file.name, localModel.getContentAsBinary(path), function(e:Event):void {
				callbackIfSet(callback);
			});
		}
		
		public function writeJson(object:Object, callback:Function = null):void {
			localModel.writeJson(path, object);
			updateRemote(callback);
		}
		
		public function writeText(text:String, callback:Function = null):void {
			localModel.writeText(path, text);
			updateRemote(callback);
		}
		
		public function writeBinary(data:ByteArray, callback:Function = null):void {
			localModel.writeBinary(path, data);
			updateRemote(callback);
		}
		
		public function sync(callback:Function = null):void {
			var finish:Function = function(i:Item):void {
				dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCED, self));
				callbackIfSet(callback);
			}
			if (!isLocalAvailable()) {
				makeLokalAvailable(finish);
			}
			else {//is local availble
				isRemoteAvailable(function(exists:Boolean):void {
					if(!exists)
						updateRemote(finish); 
					else {
						makeLokalAvailable(finish);
						/*var localVersion = getLocalVersion();
						var remoteVersion = getRemoteVersion();
						if (remoteVerion() == localVersion())
							finish(this);
						else if (remoteVerion + 1 == localVersion)
							updateRemote(finish);
						else if ((remoteVerion - 1 == localVersion))
							makeLokalAvailable(finish);
						else {
							dispatchEvent(new IOEvent(IOEvent.ON_FILE_CORRUPTED, self));
							callbackIfSet(callback);
						}*/							
					}					
				});
			}
		}
		
		
		public function create(callback:Function = null):void {
			var finish:Function = function(i:Item):void {
				dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCED, self));
				callbackIfSet(callback);
			}
			if (!isLocalAvailable()){
				createLocal(function(item:Item = null):void {
					isRemoteAvailable(function(exists:Boolean):void {
						if(!exists)
							createRemote(finish);
						else 
							callbackIfSet(finish);
					});
				});
			}
			else {//is local availble
				isRemoteAvailable(function(exists:Boolean):void {
					if(!exists)
						createRemote(finish);
					else //check version
						callbackIfSet(finish);
				});
			}
		}
		
			private function createLocal(callback:Function = null):void {
				localModel.create(path);
				callbackIfSet(callback);
			}
			
			private function createRemote(callback:Function = null):void {				
				if (isDir)
					remoteModel.createFolder(path, function(item:Item = null):void {
						callbackIfSet(callback);
					});
				else if (isLocalAvailable())
					updateRemote(callback);
				else 
					callbackIfSet(callback);
			}
			
		public function remove(callback:Function = null):void {
			var finish:Function = function(callback:Function = null):void {
				App.instance.dispatchEvent(new IOEvent(IOEvent.ON_FILE_DELETED, self));
				state = ITEM_STATE_UNINITIALIZED;
				callbackIfSet(callback);
			}
			if (isLocalAvailable()) {
				removeLocal(function(item:Item):void {
					isRemoteAvailable(function(exists:Boolean):void {
						if(exists)
							removeRemote(function(item:Item):void {
								finish(callback);
							});
						else 
							finish(callback);				
					});
				});
			}
			else{
				isRemoteAvailable(function(exists:Boolean):void {
					if(exists)
						removeRemote(function(item:Item):void {
							finish(callback);
						});
					else
						finish(callback);
				});
			}
		}
			
			public function removeLocal(callback:Function = null):void {
				localModel.remove(path);
				callbackIfSet(callback);
			}
			
			private function removeRemote(callback:Function = null):void {
				remoteModel.deleteFile(path, function(e:Event):void {
					callbackIfSet(callback);
				});
			}
			
		public function getContentAsBinary(callback:Function):void {
			if (!isLocalAvailable()) {
				makeLokalAvailable(function(item:Item):void {
					callback(localModel.getContentAsBinary(path));
				});
			}
			else {
				callback(localModel.getContentAsBinary(path));
			}
		}
		
		public function getContentAsText(callback:Function):void {
			if (!isLocalAvailable()) {
				makeLokalAvailable(function(item:Item):void {
					callback(localModel.getContentAsText(path));
				});
			}
			else {
				callback(localModel.getContentAsText(path));
			}
		}
		
		public function getContentAsJson(callback:Function):void {
			if (!isLocalAvailable()) {
				makeLokalAvailable(function(item:Item):void {
					callback(localModel.getContentAsJson(path));
				});
			}
			else {
				callback(localModel.getContentAsJson(path));
			}
		}
		
		public function createClipboard():Clipboard {				
			if(!isLocalAvailable())			
				return new Clipboard();
			
			var transfer:Clipboard = new Clipboard();
			transfer.setData(ClipboardFormats.FILE_LIST_FORMAT, 
				new Array(getLocalFile()), 
				false); 
			
			return transfer; 
		};
		
		private function callbackIfSet(callback:Function = null, param:*= null):void {
			if (callback != null)
				callback((param == null) ? self : param);
		}
		
		override public function toString():String {
			var s:String = "Item [bytes=" + bytes  + "\n";
			s	+=  ", hash=" + (hash == null ? "null" : hash) + "\n";
			s	+=  ", revision=" + (revision == null ? "null" : revision)  + "\n";
			s	+=  ", isDir=" + (isDir == true)  + "\n";
			s	+=  ", mimeType=" + (mimeType == null ? "null" : mimeType) + "\n";
			s	+=  ", modified=" + (modified == null ? "null" : modified.toString()) + "\n";
			s	+=  ", root=" + (root == null ? "null" : root) + "\n";
			s	+=  ", path=" + (path == null ? "null" : path) + "\n";
			s	+=  ", size=" + (size == null ? "null" : size) + ']';
			//s	+=  ", childs=" + (childs == null || childs.length == 0 ? "null" : (childs as Array).join()) + "]";
			return s;
		}
	}
}