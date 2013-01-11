package nodebox.io.provider.nodebox 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import m.app.AppEvent;
	import mx.utils.URLUtil;
	import com.adobe.serialization.json.JSON;
	import nodebox.App;
	import ru.inspirit.net.MultipartURLLoader;
 
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	
	public class NodeboxModel extends EventDispatcher
	{
		protected static const LOGIN_RESULT:String        = 'login_result';
		
		
		protected static const ACCOUNT_INFO:String        = 'account_info';
		/**
		 * model type DropboxFile
		 */
		protected static const NODEBOX_FILE:String        = 'NODEBOX_FILE';
		/**
		 * model type Array Of DropboxFile
		 */
		protected static const NODEBOX_FILE_LIST:String   = 'NODEBOX_FILE_list';
		/**
		 * model type SharesInfo
		 */
		protected static const DELTA_INFO:String          = 'delta_info';
		/**
		 */
		private var sessionKey:String;
		private var server:String;
		private var _config:Object = { };
		
		/**
		 * build full URL string by given values.
		 *  
		 * @param host
		 * @param target
		 * @param protocol
		 * @return built string
		 */
		protected function buildFullURL(host:String, target:String, protocol:String = 'https'):String{
			var portString:String = '';//(_config.port == 80) ? "" : (":" + _config.port);
			if (host.indexOf('http://') == 0 || host.indexOf('https://') == 0) {
				protocol = '';
			} else {
				protocol += "://";
			}
			
			var params:String = sessionKey ? '?sessionKey=' + sessionKey +'&': ''; 
			
			return protocol + host + portString + (target == "" ? "" : '/' + target + params); 
		}
		
		/** 
		 * This method authenitcates a user
		 */
		public function login(server:String, name:String, password:String):void {
			this.server = server;
			
			var req:URLRequest = buildURLRequest(server, 'auth', {'user':name, 'pass':password}, URLRequestMethod.POST);
			
			load(req, NodeboxEvent.LOGIN_RESULT, NodeboxEvent.LOGIN_FAULT, LOGIN_RESULT);
		}
		
		/** 
		 * This method calls for information about the logged in user.
		 */
		public function accountInfo():void {
			var req:URLRequest = buildURLRequest(server, 'account/info', {}, URLRequestMethod.GET);
			
			load(req, NodeboxEvent.ACCOUNT_INFO_RESULT, NodeboxEvent.ACCOUNT_INFO_FAULT, ACCOUNT_INFO);
		}
		
		/** 
		 * This method uploads the content of a file.
		 */
		public function putFile(path:String, fileName:String, data:ByteArray):void {
			var req:URLRequest = buildURLRequest(server, 'io/'+path+fileName, {}, URLRequestMethod.POST);
			var urlLoader:MultipartURLLoader = new MultipartURLLoader();
			
			urlLoader.addFile(data, fileName);
			
			urlLoader.addEventListener(Event.COMPLETE, uploadCompleteHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, uploadIOErrorHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, uploadSecurityErrorHandler);
			urlLoader.load(req.url);
		}
		
		/** 
		 * This method 
		 */
		public function createFolder(path:String):void {
			var req:URLRequest = buildURLRequest(server, 'io/'+path, {}, 'MKCOL');
			
			load(req, NodeboxEvent.FILE_CREATE_FOLDER_RESULT, NodeboxEvent.FILE_CREATE_FOLDER_FAULT, NODEBOX_FILE);
		}
		
		/** 
		 * This method 
		 */
		public function deleteFile(file:String):void {
			var req:URLRequest = buildURLRequest(server, 'io/'+file, {}, URLRequestMethod.DELETE);
			
			load(req, NodeboxEvent.FILE_DELETE_RESULT, NodeboxEvent.FILE_DELETE_FAULT, NODEBOX_FILE);
		}
		
		/** 
		 * This method 
		 */
		public function getFile(file:String, revision:String = ""):void {
			App.instance.logger.info('calling for file: '+file);
			var req:URLRequest = buildURLRequest(server, 'io/'+file, {}, URLRequestMethod.GET);
			
			load(req, NodeboxEvent.GET_FILE_RESULT, NodeboxEvent.GET_FILE_FAULT, "", URLLoaderDataFormat.BINARY);
		}
		
		/** 
		 * This method 
		 */
		public function getMetadata(path:String, limit:int = 1000, recursive:Boolean = true):void {
			var req:URLRequest = buildURLRequest(server, 'info/metadata/'+path, {}, URLRequestMethod.GET);
			
			load(req, NodeboxEvent.METADATA_RESULT, NodeboxEvent.METADATA_FAULT, NODEBOX_FILE);
		}
		
		/** 
		 * This method 
		 */
		public function delta(cursorRevision:String):void {
			this.dispatchEvent(new NodeboxEvent(NodeboxEvent.DELTA_FAULT));
			this.dispatchEvent(new NodeboxEvent(NodeboxEvent.DELTA_RESULT));
		}
		
		/**
		 * @private
		 * 
		 * dispatch a dropbox event.
		 *  
		 * @param evtType
		 * @param relatedEvent
		 * @param resultObject
		 */
		protected function dispatchNodeboxEvent(
			evtType:String, relatedEvent:Event, resultObject:Object):void
		{
			var nodeboxEvent:NodeboxEvent = new NodeboxEvent(evtType);
			nodeboxEvent.resultObject = resultObject;
			nodeboxEvent.relatedEvent = relatedEvent;
			this.dispatchEvent(nodeboxEvent);
		}
		
		/**
		 * @private
		 * 
		 * @param evt
		 */
		protected function ioErrorHandler(evt:IOErrorEvent):void{
			App.instance.dispatchEvent(new AppEvent(AppEvent.ON_APP_CONNECT_ERROR));
		}
		
		/**
		 * @private
		 *  
		 * @param evt
		 */
		protected function securityErrorHandler(evt:SecurityErrorEvent):void{
			App.instance.dispatchEvent(new AppEvent(AppEvent.ON_APP_CONNECT_ERROR));
		}
		
		
		/**
		 * Load a URL request.
		 * 
		 * @param urlRequest
		 * @param evtResultType
		 * @param evtFaultType
		 * @param resultType
		 * @param dataFormat
		 * @return urlLoader
		 */
		protected function load(urlRequest:URLRequest, 
								evtResultType:String, evtFaultType:String,
								resultType:String = null,
								dataFormat:String = URLLoaderDataFormat.TEXT):URLLoader
		{
			var urlLoader:NodeboxURLLoader = new NodeboxURLLoader();
			urlLoader.dataFormat 		= dataFormat;
			urlLoader.eventResultType 	= evtResultType;
			urlLoader.eventFaultType 	= evtFaultType;
			urlLoader.resultType 		= resultType;
			
			urlLoader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			urlLoader.load(urlRequest);
			return urlLoader;
		}
		
		/**
		 * Build a OAuth URL request.
		 *  
		 * @param apiHost
		 * @param target
		 * @param params
		 * @param httpMethod
		 * @param protocol
		 * @return built URL request
		 */
		protected function buildURLRequest(apiHost:String, target:String, params:Object,
									    httpMethod:String = URLRequestMethod.GET,
									    protocol:String = 'https'):URLRequest
		{
			var url:String = this.buildFullURL(apiHost, target, protocol);
			var urlRequest:URLRequest = new URLRequest();
			urlRequest.method = httpMethod;
			urlRequest.data = URLUtil.objectToString(params, '&');
			urlRequest.url = url;
			return urlRequest;
		}
		
		/**
		 * @private
		 * 
		 * Listener function when urlLoader is load complete.
		 * The result will be formatted to object if the type is set in
		 * NodeboxURLLoader.
		 *  
		 * @param evt
		 */
		protected function loadCompleteHandler(evt:Event):void
		{
			var urlLoader:NodeboxURLLoader = NodeboxURLLoader(evt.target);
			var resultObject:*;
			try {
				if (urlLoader.resultType == LOGIN_RESULT) {
					var data:Object = com.adobe.serialization.json.JSON.decode(urlLoader.data);
					sessionKey = data.sessionKey;
					App.instance.logger.info('reciving session key: '+sessionKey);
					
				} else if (urlLoader.resultType == ACCOUNT_INFO) {
					resultObject = com.adobe.serialization.json.JSON.decode(urlLoader.data);
					
				} else if (urlLoader.resultType == NODEBOX_FILE) {
					resultObject = com.adobe.serialization.json.JSON.decode(urlLoader.data);
				/*} else if (urlLoader.resultType == NODEBOX_FILE_LIST) {
					App.instance.logger.info('getMetadata response: '+urlLoader.data);
					var array:Array = new Array();
					var resultArray:* = com.adobe.serialization.json.JSON.decode(urlLoader.data);
					for each (var ro:Object in resultArray) {
						var df:NodeboxFile = new NodeboxFile();
						df.decode(ro);
						array.push(df);
					}
					resultObject = array;*/
				} else if (urlLoader.resultType == DELTA_INFO) {
					resultObject = com.adobe.serialization.json.JSON.decode(urlLoader.data);
				} else {
					resultObject = urlLoader.data;
				}
			} catch (e:Error) {
				App.instance.logger.error(e.message);
				this.dispatchNodeboxEvent(urlLoader.eventFaultType, evt, e, e.message);
				return;
			}
			
			this.dispatchNodeboxEvent(urlLoader.eventResultType, evt, resultObject);
		}	
		
		/**
		 * @private
		 * 
		 * Listener for upload request. 
		 *  
		 * @param evt
		 */
		protected function uploadCompleteHandler(evt:Event):void
		{
			var m:MultipartURLLoader = MultipartURLLoader(evt.target);
			this.dispatchNodeboxEvent(NodeboxEvent.PUT_FILE_RESULT, evt, com.adobe.serialization.json.JSON.decode(m.loader.data));
		}
		
		/**
		 * @private
		 * 
		 * Listener for upload request.
		 *  
		 * @param evt
		 * 
		 */
		protected function uploadIOErrorHandler(evt:IOErrorEvent):void
		{
			var m:MultipartURLLoader = MultipartURLLoader(evt.target);
			this.dispatchNodeboxEvent(NodeboxEvent.PUT_FILE_FAULT, evt, m.loader.data);
		}
		
		/**
		 * @private
		 * 
		 * Listener for upload request.
		 *  
		 * @param evt
		 * 
		 */
		protected function uploadSecurityErrorHandler(evt:SecurityErrorEvent):void
		{
			var m:MultipartURLLoader = MultipartURLLoader(evt.target);
			this.dispatchNodeboxEvent(NodeboxEvent.PUT_FILE_FAULT, evt, m.loader.data);
		}
	}
}

import flash.net.URLLoader;

	/**
 * Internal class. Extends flash.net.URLLoader, add 3 properties. 
 * 
 * @author yinzeshuo
 */
 
internal class NodeboxURLLoader extends URLLoader
{
	/**
	 * define class type of result, can be REQUEST_TOKEN|ACCESS_TOKEN|ACCOUNT_INFO|NODEBOX_FILE.
	 * 
	 * REQUEST_TOKEN & ACCESS_TOKEN : set to DropboxConfig when type is requestToken & accessToken.
	 * ACCOUNT_INFO : return an AccountInfo object
	 * NODEBOX_FILE : return an DropboxFile object
	 * NODEBOX_FILE_LIST : return an array of DropboxFile object
	 * others : return response string.*/
	 
	public var resultType:String;
	
	/**
	 * define dispatch event type*/
	 
	public var eventResultType:String;
	/**
	 * define dispatch event type */
	 
	public var eventFaultType:String;
}
