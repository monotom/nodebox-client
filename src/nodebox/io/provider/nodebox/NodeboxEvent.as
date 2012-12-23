package nodebox.io.provider.nodebox
{
	import flash.events.Event;
	
	/**
	 * Dropbox Event.
	 *  
	 * @author yinzeshuo
	 * 
	 */
	public class NodeboxEvent extends Event
	{
		
		public static const LOGIN_FAULT:String = 'NodeboxEvent_LoginFault';
		public static const LOGIN_RESULT:String = 'NodeboxEvent_LoginResult';
		
		public static const ACCOUNT_INFO_RESULT:String = 'NodeboxEvent_AccountInfoResult';
		public static const ACCOUNT_INFO_FAULT:String = 'NodeboxEvent_AccountInfoFault';
		public static const PUT_FILE_RESULT:String = 'NodeboxEvent_PutFileResult';
		public static const PUT_FILE_FAULT:String = 'NodeboxEvent_PutFileFault';
		public static const FILE_COPY_RESULT:String = 'NodeboxEvent_FileCopyResult';
		public static const FILE_COPY_FAULT:String = 'NodeboxEvent_FileCopyFault';
		public static const FILE_CREATE_FOLDER_RESULT:String = 'NodeboxEvent_FileCreateFolderResult';
		public static const FILE_CREATE_FOLDER_FAULT:String = 'NodeboxEvent_FileCreateFolderFault';
		public static const FILE_DELETE_RESULT:String = 'NodeboxEvent_FileDeleteResult';
		public static const FILE_DELETE_FAULT:String = 'NodeboxEvent_FileDeleteFault';
		public static const FILE_MOVE_RESULT:String = 'NodeboxEvent_FileMoveResult';
		public static const FILE_MOVE_FAULT:String = 'NodeboxEvent_FileMoveFault';
		public static const GET_FILE_RESULT:String = 'NodeboxEvent_GetFileResult';
		public static const GET_FILE_FAULT:String = 'NodeboxEvent_GetFileFault';
		public static const METADATA_RESULT:String = 'NodeboxEvent_MetadataResult';
		public static const METADATA_FAULT:String = 'NodeboxEvent_MetadataFault';
		
		/**
		 * added in v1
		 */
		public static const REVISION_RESULT:String 	= "NodeboxEvent_RevisionResult";
		public static const REVISION_FAULT:String 	= "NodeboxEvent_RevisionFault";
		public static const SEARCH_RESULT:String	= 'NodeboxEvent_SearchResult';
		public static const SEARCH_FAULT:String		= 'NodeboxEvent_SearchFault';
		public static const DELTA_RESULT:String		= 'NodeboxEvent_DeltaResult';
		public static const DELTA_FAULT:String		= 'NodeboxEvent_DeltaFault';
		
		/**
		 * related URLLoader Event. 
		 */
		public var relatedEvent:Event;
		/**
		 * result Object
		 * 1. object{key:'', secret:''} when you called DropboxClient.requestToken() or DropboxClient.accessToken()
		 * 2. AccountInfo when you called accountInfo()
		 * 3. DropboxFile when you called files API
		 * 4. ByteArray when you called getFile()
		 * 5. response string.
		 */
		public var resultObject:Object;
		
		/**
		 * Constructor
		 *  
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 */
		public function NodeboxEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * clone function.
		 *  
		 * @return a cloned instance of NodeboxEvent
		 */
		override public function clone():Event
		{
			var result:NodeboxEvent = new NodeboxEvent(type, bubbles, cancelable);
			result.relatedEvent = this.relatedEvent;
			result.resultObject = this.resultObject;
			return result;
		}
	}
}