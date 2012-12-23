package m.ui {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import m.ui.components.Button;
	import mx.containers.Box;
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import spark.components.TitleWindow;

	public class ChildWindow extends TitleWindow{
		public var minimizeButton:Button = new Button();
		public var resizeButton:Button   = new Button();
		public var content:Box 		     = new Box();
		
		private var oldHeight:Number;
		private var oldWidth:Number;
		private var oldX:Number;
		private var oldY:Number;
		private var oldMouseX:Number;
		private var oldMouseY:Number;
				
		public function ChildWindow(){
			super();	
			minHeight = 150;
		}
		
		public function show(parent:DisplayObject = null, center:Boolean = true, modal:Boolean = false):void {
			if (parent == null)
				parent = FlexGlobals.topLevelApplication as DisplayObject;	
				
			PopUpManager.addPopUp(this, parent, modal);
			if (center)
				PopUpManager.centerPopUp(this);
		}
		
		public function close():void {
			PopUpManager.removePopUp(this);
		}
		
		[ArrayElementType("mx.core.IVisualElement")]
		override public function set mxmlContent(value:Array):void {
			_mxmlContent = value;
		}
		private var _mxmlContent:Array;

		private var _scrollRect:Rectangle;
		override protected function createChildren():void {			
			super.createChildren();
			
			if( _mxmlContent != null ) {
				for (var i:int = 0; i < _mxmlContent.length; i++) {   
					var elt:IVisualElement = _mxmlContent[i];
					addElement(elt);
				}
			}
			
			super.addElement(minimizeButton);
			super.addElement(resizeButton);
			super.addElement(content);
			
			_scrollRect = new Rectangle(0, 0, width, height);		
			content.scrollRect = _scrollRect;
			content.width = width;
			content.height = height - 19;
			
			content.setStyle("height", "100%");	
			content.setStyle("width", "100%");	
			content.setStyle("paddingTop", "10");	
			content.setStyle("paddingRight", "10");	
			content.setStyle("paddingBottom", "10");	
			content.setStyle("paddingLeft", "10");	
			
			setStyle("cornerRadius", 10);
			
			//init child minimize AppButton
			minimizeButton.right = 25;
			minimizeButton.height = 20;
			minimizeButton.width = 20;
			minimizeButton.height = 20;
			minimizeButton.top = -27;
			minimizeButton.source = "assets/img/icons/minimize.png";
			minimizeButton.addEventListener(MouseEvent.MOUSE_UP, onMinimize);
			
			//init child resize AppButton
			resizeButton.right = 10;
			resizeButton.height = 20;
			resizeButton.width = 20;
			resizeButton.height = 20;
			resizeButton.bottom = 0;
			resizeButton.source = "assets/img/icons/resize.png";
			resizeButton.addEventListener(MouseEvent.MOUSE_DOWN, onResizeStart);
			
			//init child close AppButton
			addEventListener(CloseEvent.CLOSE, onClose);
		}
		
		public function addOnClose(callback:Function):void {
			addEventListener(CloseEvent.CLOSE, callback);
		}
		
		override public function set title(title:String):void{
			//set title of child window
			super.title = '        ' + title; 
		}
			
		override public function get title():String{
			//strip window title and return
			return super.title ? super.title.replace(/^\s+|\s+$/gs, '') : ""; 
		}
		
		protected function onMinimize(event:MouseEvent = null):void {
			//remove minimize handler
			minimizeButton.removeEventListener(MouseEvent.MOUSE_UP, onMinimize);
			
			//add un minimize handler
			minimizeButton.addEventListener(MouseEvent.MOUSE_UP, onUnMinimize);
			
			//hide content of child window
			content.visible = false;
			
			//save old height
			oldHeight = height;
		
			//set minimzed height
			height = minHeight;		
		}
		
		protected function onUnMinimize(event:MouseEvent = null, doHeight:Boolean = true):void {
			//add minimize handler
			minimizeButton.addEventListener(MouseEvent.MOUSE_UP, onMinimize);
			
			//remove un minimize handler
			minimizeButton.removeEventListener(MouseEvent.MOUSE_UP, onUnMinimize);
			
			//show content of child window
			content.visible = true;
			
			//restore old height, if neede, not needed if window is resized, when minimized
			if(doHeight)
				height = oldHeight;
		}
		
		protected function onResizeStart(event:MouseEvent):void {
			//store old mouse positions
			oldMouseX = event.stageX;
			oldMouseY = event.stageY;
			
			//add move handler
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onResize);
			stage.addEventListener(MouseEvent.MOUSE_UP, onResizeStop);		
			
			//call unminimize, when child is resized and minimzed, dont restore height
			onUnMinimize(null, false);
		}
		
		protected function onResize(event:MouseEvent):void {
			//set new height and width with relative mouse coords
			width  = width  - (oldMouseX - event.stageX);
			height = height - (oldMouseY - event.stageY);		
			
			//store last mouse positions
			oldMouseX = event.stageX;
			oldMouseY = event.stageY;
			
			_scrollRect.width = width;
			_scrollRect.height = height;
			content.scrollRect = _scrollRect;
			
			content.width = width;
			content.height = height - 19;
		}
		
		protected function onResizeStop(event:MouseEvent):void {				
			//remove move handlers
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onResize);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onResizeStop);			
		}
		
		private function onClose(event:Event):void {
			close();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
		//override add Element functions, so content is placed in content
		override public function addElement(element:IVisualElement):IVisualElement {
			return content.addElement(element);
		}
		
		override public function addElementAt(element:IVisualElement, position:int):IVisualElement{
			return content.addElementAt(element, position);
		}
	}
}