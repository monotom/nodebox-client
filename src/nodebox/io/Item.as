package nodebox.io{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import m.io.LocalFileManager;
	import nodebox.App;
	import nodebox.io.provider.ProviderInterface;
	
	/**
	 * This class holds the informations about a remote file or folder and manages the logical operations for syncing beteen the remote an local file.
	 * 
	 * @author Tom Hanoldt.
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
		public static const ITEM_STATE_UNSYNCABLE:int = 4;
		public static const ITEM_STATE_LOCAL_CHANGED:int = 5;
		
		public var state:int = ITEM_STATE_UNINITIALIZED;
		
		public var remoteModel:ProviderInterface;
		public var localModel:LocalFileManager;
		private var self:Item;
		/** 
		 * Constructor.
		 * 
		 */
		public function Item() {
			localModel = App.instance.localFileManager;
			remoteModel = App.instance.dataProvider;
			self = this;
		}
		
		/** 
		 * Get the name of the file or folder.
		 * 
		 * @return The last segment of the file path splitted by '/'.
		 */
		public function get name():String {
			return path.split('/').pop();
		}
		
		/** 
		 * This method sets the name of the file.
		 * 
		 * @param value The new name.
		 */
		public function set name(value:String):void {
			var tmp:Array = path.split('/');
			tmp.pop();
			path = tmp.join('/') + '/' + value;
			
			//TODO if its a synced file also rename the remote file.
		}
		
		private var _path:String;
		/** 
		 * Get the relative path of the file or folder within the users desktop including the name of the file if its a file.
		 * 
		 * @return The path of the file or folder.
		 */
		public function get path():String {
			return _path;
		}
				
		/** 
		 * This normalizes and sets the path of the item
		 * 
		 * @param value The new path of that item.
		 */
		//TODO if its a synced item move the item local and remote to the new path
		public function set path(value:String):void {
			_path = normalizePath(value);  
			state = (localModel.isAvailable(_path)) ? ITEM_STATE_SYNCED : ITEM_STATE_INITIALIZED;
		}
		
		/** 
		 * This method get the path wizhout the name of the item.
		 * 
		 * @return The path of the item.
		 */
		public function get pathWithoutName():String {	
			return path.substr(0, path.length - name.length);
		}
		
		public function get localPath():String {
			return localModel.buildPath(path);
		}
		
		/** 
		 * This method returns the extension of the file or empty string if folder.
		 * 
		 * @return The extension of the file.
		 */
		public function get extension():String {
			return (name.indexOf('.') != -1) ? name.split('.').pop() : '';
		}
		
		/** 
		 * This method normalizes a path so, that ther is no ending slash if its a folder.
		 * 
		 * @param path The unnormalized path.
		 * 
		 * @return The normalized path.
		 */
		public static function normalizePath(path:String=null):String {
			return (path!=null &&path.charAt(0) == '/') ? path.substr(1) : path;
		}
		
		/** 
		 * This method copies the properties of one item to this item. Used for updates.
		 * 
		 * @param srcItem The item from wherer the propties should be coppied.
		 */
		public function importProperties(srcItem:Item):void {
			bytes		 = srcItem.bytes;
			size		 = srcItem.size;
			modified	 = srcItem.modified;
			isDir	 	 = srcItem.isDir;
			root		 = srcItem.root;
			mimeType	 = srcItem.mimeType;
			revision	 = srcItem.revision;
			isDeleted 	 = srcItem.isDeleted;
			hash		 = srcItem.hash;
						
			//remove unpresent childs
			var subItem:Item
			for each(subItem in self.childs) {
				if (srcItem.childs.hasOwnProperty(subItem.path))
					continue;
				
				delete self.childs[subItem.path];				
			}
			
			//import child data
			for each(subItem in srcItem.childs) {
				if (!childs.hasOwnProperty(subItem.path))
					childs[subItem.path] = subItem;				
				else
					childs[subItem.path].importProperties(subItem);
			}	
		}
		
		/** 
		 * This method returns the File object of the local file representation.
		 * 
		 * @return the local file.
		 */
		public function getLocalFile():File {
			return localModel.getFile(path);
		}
		
		/** 
		 * This method tests if the remote file is local available.
		 * 
		 * @return True if exsits, false otherwise.
		 */
		public function isLocalAvailable():Boolean {
			if (state == ITEM_STATE_UNINITIALIZED) return false;
			
			return localModel.isAvailable(path);
		}
		
		/** 
		 * This method tests if he file is remote available.
		 * 
		 * @return True if exsits, false otherwise.
		 */
		public function isRemoteAvailable(callback:Function):void {
			if (state == ITEM_STATE_UNINITIALIZED) 
				callback(false);
			else
				remoteModel.isAvailable(path, callback);
		}
		
		/**
		 * Synchronizes this item. Downloads, deltes, updates and synchronizes this and childs
		 * 
		 * @param	callback
		 */
		public function sync(callback:Function = null):void {
			if (state == ITEM_STATE_UNINITIALIZED) return ;
			if (state == ITEM_STATE_SYNCING) return ;
			
			state = ITEM_STATE_SYNCING;	
			
			dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCING, self));	
			remoteModel.getMetadata(path, function(newVersionItem:Item):void {
				var child:Item;
				
				if (newVersionItem.isDeleted) {
					if(isDir)
						for each(child in childs)
							child.remove();
						
					remove();//set the state
					return callbackIfSet(callback);
				}
				
				var oldRevision:String = revision;
				importProperties(newVersionItem);
				
				if (oldRevision != revision
				|| !isLocalAvailable()) {					
					loadRemoteChanges(function(i:Item):void {//sets the state			
						callbackIfSet(callback);
					});
				}
				else {
					state = ITEM_STATE_SYNCED;
					dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCED, self));				
					callbackIfSet(callback);
				}
				
				if(isDir)
					for each(child in childs)
						child.sync();
					
			}, 1000, isDir);
		}
		
		/** 
		 * This method loads the remote file and creates or overrides the local file.
		 * 
		 * @param callback A method that is called if the operation is finished.
		 * @param overrideOnConflikt //TODO implement
		 */
		private function loadRemoteChanges(callback:Function = null, overrideOnConflict:Boolean = true):void {
			if (state == ITEM_STATE_UNINITIALIZED) return ;
			
			if(isLocalAvailable())
				localModel.remove(path);
				
			makeLokalAvailable(function (item:Item):void {//sets the state
				callbackIfSet(callback, item);
			});
		}
		
		/** 
		 * This method downloads a remote file or creates a folder and sets the icon states.
		 * 
		 * @param callback A method that is called if the file is synced.
		 */
		private function makeLokalAvailable(callback:Function = null):void {
			if (state == ITEM_STATE_UNINITIALIZED) return ;
			
			App.instance.logger.info('Item.makeLokalAvailable("' + path + '")');
			
			state = ITEM_STATE_SYNCING;
			dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCING, self));
			var finish:Function = function():void {
				state = ITEM_STATE_SYNCED;
				callbackIfSet(callback);
				dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCED, self));				
			};
			
			if (isLocalAvailable()) {
				finish();
			}			
			else if (isDir) {
				localModel.createFolder(path);
				finish();
			}
			else{				
				remoteModel.getFile(path, function(data:ByteArray):void {
					localModel.writeBinary(path, data);
					finish();
				});
			}
		}
		
		/** 
		 * This method updates or creates the remote file content.
		 *
		 * @param callback A method that is called if the file is synced.
		 */
		public function updateRemote(callback:Function = null):void {
			if (state == ITEM_STATE_UNINITIALIZED) return ;
			
			App.instance.logger.info('Item.updateRemote(remotePath: ' + pathWithoutName + ' localPath:' + path);
			var file:File;
			if (isDir) {
				var childPathes:Array = [];
				for each(var child:Item in self.childs){
					child.updateRemote();
					childPathes.push(child.localPath);
				}
				
				//create and upload new files within directory
				var newItem:Item;
				var localFiles:Array = localModel.getDirectoryListening(path);
				for each(file in localFiles) {
					if (childPathes.indexOf(file.nativePath) != -1)
						continue;
					
					newItem = new Item();
					newItem.path = path+'/'+file.name;
					newItem.isDir = file.isDirectory;
					App.instance.logger.debug('upload : '+newItem.path);
					newItem.updateRemote();
				}
			}
			else {
				state = ITEM_STATE_SYNCING;
				dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCING, self));
					
				file = localModel.getFile(path);
				remoteModel.uploadFile(pathWithoutName, file.name, localModel.getContentAsBinary(path), function(e:Event):void {
					self.state = ITEM_STATE_SYNCED;
					callbackIfSet(callback);
					self.dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCED, self));
				});
			}
		}
//CREATE
		/** 
		 * This method copies the a local file or folder to the desktop and uploads the new or updated file.
		 * The path for the new file is taken from 'this' Item reference and must be set before.
		 * 
		 * @param src the local file to copy from. If its a folder it is processed recursive.
		 * 
		 * @return Inidicates if the file allready exists.
		 */
		public function copyFrom(src:File):Boolean {
			try{
				src.copyTo(localModel.getFileRefference(path), false);
				App.instance.logger.info('Item.copyTo(from:' + src.nativePath + ',"to:' + localModel.getFile(path).nativePath + '")');
			}
			catch (e:Error) {
				return false;
			}
			
			state = ITEM_STATE_SYNCING;
			dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCING, self));				
			createRemote(function(item:Item):void {
				state = ITEM_STATE_SYNCED;
				dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCED, item));
				if (src.isDirectory) 
					createRecursiveRemote(src.getDirectoryListing(), path);
			});
			return true;
		}
		
		/** 
		 * This method called internally to process importing folders recursive.
		 */
		private function createRecursiveRemote(files:Array, subPath:String = ''):void {
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
		
		/** 
		 * This method creates the remote file or folder.
		 *
		 * @param callback A method that is called if the file is synced.
		 */
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
//REMOVE	
		/** 
		 * This method deletes a file local and remote.
		 *
		 * @param callback A method that is called if the file is synced.
		 */
		public function remove(callback:Function = null):void {
			App.instance.logger.info('remove for '+path);
			
			state = ITEM_STATE_SYNCING;
			dispatchEvent(new IOEvent(IOEvent.ON_FILE_SYNCING, self));
			var finish:Function = function(i:Item = null):void {
				App.instance.dispatchEvent(new IOEvent(IOEvent.ON_FILE_DELETED, self));
				state = ITEM_STATE_UNINITIALIZED;
				callbackIfSet(callback);
			}
					
			if (isLocalAvailable()) {
				removeLocal(function(i:Item):void {
					removeRemote(finish);
				});
			}
			else {
				removeRemote(finish);
			}
		}
			
			/** 
			 * This method deletes the local file.
			 *
			 * @param callback A method that is called if the file is synced.
			 */
			public function removeLocal(callback:Function = null):void {
				localModel.remove(path);
				callbackIfSet(callback);
			}
			
			/** 
			 * This method deletes a file remote.
			 *
			 * @param callback A method that is called if the file is synced.
			 */
			private function removeRemote(callback:Function = null):void {
				isRemoteAvailable(function(exists:Boolean):void {
					if (exists) {
						remoteModel.deleteFile(path, function(e:Event):void {
							callbackIfSet(callback);					
						});
					}
					else {
						callbackIfSet(callback);
					}
				});				
			}
			
//READ/WRITE	
		/** 
		 * This method wites an object to the local file and updates the remote file.
		 *
		 * @param callback A method that is called if the file is synced.
		 */
		public function writeJson(object:Object, callback:Function = null):void {
			localModel.writeJson(path, object);
			updateRemote(callback);
		}
		
		/** 
		 * This method writes a txt to the local file and updates the remote file.
		 *
		 * @param callback A method that is called if the file is synced.
		 */
		public function writeText(text:String, callback:Function = null):void {
			localModel.writeText(path, text);
			updateRemote(callback);
		}
		
		/** 
		 * This method writes binary content to the local file and updates the remote file.
		 *
		 * @param callback A method that is called if the file is synced.
		 */
		public function writeBinary(data:ByteArray, callback:Function = null):void {
			localModel.writeBinary(path, data);
			updateRemote(callback);
		}
			
		/** 
		 * This method reads the content of the local file as binary.
		 *
		 * @param callback A method that is called if the operation is finished.
		 */
		public function getContentAsBinary(callback:Function):void {
			makeLokalAvailable(function(item:Item):void {
				callback(localModel.getContentAsBinary(path));
			});
		}
		
		/** 
		 * This method gets the content of the local file as text.
		 *
		 * @param callback A method that is called if the operation is finished.
		 */
		public function getContentAsText(callback:Function):void {
			makeLokalAvailable(function(item:Item):void {
				callback(localModel.getContentAsText(path));
			});
		}
		
		/** 
		 * This method reads the content of the local file and performaes a json decode.
		 *
		 * @param callback A method that is called if the operation is finished.
		 */
		public function getContentAsJson(callback:Function):void {
			makeLokalAvailable(function(item:Item):void {
				callback(localModel.getContentAsJson(path));
			});
		}
		
		/** 
		 * This method creates the clippord data for this item so and can be copied to the native os.
		 */
		public function createClipboard():Clipboard {				
			var transfer:Clipboard = new Clipboard();
			transfer.setData(ClipboardFormats.FILE_LIST_FORMAT, 
				isLocalAvailable() ? new Array( getLocalFile()) : new Array( ), 
				false); 
			
			return transfer; 
		};
		
		/** 
		 * This method creates the clippord data for this item so and can be copied to the native os.
		 */
		public function copyToClipboard():void {				
			if(!isLocalAvailable())			
				return ;
			
			Clipboard.generalClipboard.clear();
			var f:File = null;
			try {
				f = getLocalFile();
			}
			catch (e:Error ) { }
			Clipboard.generalClipboard.setData(ClipboardFormats.FILE_LIST_FORMAT, new Array(f), false);
		};
		
		/** 
		 * This method 
		 *
		 * @param callback A method that is called if the file is synced.
		 */
		private function callbackIfSet(callback:Function = null, param:*= null):void {
			if (callback != null)
				callback((param == null) ? self : param);
		}
		
		/** 
		 * This method ovverrides the toString method with information about this item.
		 * 
		 * @return Informnations about this item.
		 */
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