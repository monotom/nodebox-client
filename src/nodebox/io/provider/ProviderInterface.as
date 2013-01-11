package nodebox.io.provider {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	import flash.events.Event;
	import flash.utils.ByteArray;
	import nodebox.plugins.PluginInterface;
	import spark.components.Image;
	
	public interface ProviderInterface extends PluginInterface{
		/**
		 * This image will be displayed next to the login form and on the desktop background.
		 * 
		 * @return A image with the provider logo.
		 */
		function getImage():Image;
		
		/** 
		 * This string will be displayed next to the login form.
		 * 
		 * @return Information about the login process.
		 */
		function getInfo():String;
		
		/** 
		 * Get the elements that collects the data needed for the login process
		 * 
		 * @return An array containing IVisualElements or an second array containing IVisualElements that will be displayed in a row.
		 */
		function getLoginformFields():Array;
		
		/** 
		 * This method is called when the connect button of the login form is pressed.
		 * 
		 * @param e The event that triggered the call of that method.
		 */
		function onLogin(e:Event = null):void;
		
		/** 
		 * This method gives a unique string for storing the users data in the local file system.
		 * So many users can store their data with the same client.
		 * 
		 * @return A unique string corresponding to the logged in account.
		 */
		function uniqueUserId():String;
		
		/** 
		 * This method gets information about the logged in user from the data provider. 
		 * 
		 * @param callback A method that is called when the informations are available.
		 */
		function getAccountInfo(callback:Function):void;
		
		/** 
		 * This method tests if a file exists on the provider side.
		 * 
		 * @param path Relative path to the file within the users desktop.
		 * @param callback A method that is called when the informations are available.
		 */
		function isAvailable(path:String, callback:Function):void;
		
		/** 
		 * This method uploads a new or changed file to the file hoster.
		 * 
		 * @param path Relative path to the file within the users desktop.
		 * @param name The name of the file.
		 * @param data The content of the file in form of a byte array.
		 * @param callback A method that is called when the informations are available.
		 */
		function uploadFile(path:String, name:String, data:ByteArray, callback:Function = null):void;
		
		/** 
		 * This method creates a folder recursive remote.
		 * 
		 * @param path Relative path to the file within the users desktop.
		 * @param callback A method that is called when the informations are available.
		 */
		function createFolder(path:String, callback:Function = null):void;
		
		/** 
		 * This method deletes a remote file.
		 * 
		 * @param file Relative path to the file within the users desktop.
		 * @param callback A method that is called when the informations are available.
		 */
		function deleteFile(file:String, callback:Function = null):void;
		
		/** 
		 * This method gets the content of a remote file.
		 * 
		 * @param file Relative path to the file within the users desktop.
		 * @param callback A method that is called when the informations are available.
		 * @param revision The revision of the file that content should retrieved.
		 */
		function getFile(file:String, callback:Function, revision:String = ""):void;
		
		/** 
		 * This method gets the metadata of a file and should produce a nodebox.io.Item. @see nodebox.io.Item.
		 * 
		 * @param path Relative path to the file within the users desktop.
		 * @param callback A method that is called when the informations are available.
		 * @param limit If supported limits the count of files.
		 * @param recursive If supported and the path points to a directory process the directory recursive.
		 */
		function getMetadata(path:String, callback:Function, limit:int = 1000, recursive:Boolean = true):void;
	}
}