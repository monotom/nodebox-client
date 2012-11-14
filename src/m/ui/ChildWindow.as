package m.ui {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	import flash.display.Sprite;
	import m.ui.components.Button;
	import mx.binding.utils.BindingUtils;
	import mx.containers.HBox;
	import mx.controls.scrollClasses.ScrollBar;
	import mx.core.FlexSprite;
	import mx.core.UIComponent;
	import spark.components.Scroller;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import mx.events.CloseEvent;
	import flash.events.MouseEvent;
	
	import mx.core.IFlexDisplayObject;
	import mx.core.IVisualElement;
	import mx.managers.PopUpManager;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.TitleWindow;
	
	//import m.ui.skins.ResizableTitleWindowSkin;
	
	public class ChildWindow extends TitleWindow{
		public var statusLabel:Label        = new Label(); 			
		public var minimizeButton:Button = new Button();
		public var resizeButton:Button   = new Button();
		public var content:Group	   		= new Group();
		
		private var oldHeight:Number;
		private var oldWidth:Number;
		private var oldX:Number;
		private var oldY:Number;
		private var oldMouseX:Number;
		private var oldMouseY:Number;
				
		public function ChildWindow(){
			super();	
			minHeight = 150;
			//content.clipAndEnableScrolling = true;
			//setStyle("skinClass", ResizableTitleWindowSkin);
		}
		
		public function show(parent:DisplayObject = null, center:Boolean = true, modal:Boolean = false):void {
			PopUpManager.addPopUp(this, parent, modal);
			if (center)
				PopUpManager.centerPopUp(this);
		}
		
		public function close():void {
			PopUpManager.removePopUp(this);
		}
		
		override protected function createChildren():void {			
			super.createChildren();
			
			//add view elements
			super.addElement(statusLabel);
			super.addElement(minimizeButton);
			super.addElement(resizeButton);
			
			var scroller:HBox = new HBox();
			scroller.addElement(content);
			
			super.addElement(scroller);
			
			content.setStyle("height", "100%");	
			content.setStyle("width", "100%");	
			content.setStyle("paddingTop", "10");	
			content.setStyle("paddingRight", "10");	
			content.setStyle("paddingBottom", "10");	
			content.setStyle("paddingLeft", "10");	
			
			setStyle("cornerRadius", 10);
			
			//init child status label
			statusLabel.setStyle("backgroundColor", "#BCBCBC");
			statusLabel.setStyle("paddingLeft", 3);
			statusLabel.setStyle("paddingRight", 3);
			statusLabel.setStyle("paddingTop", 3);
			statusLabel.setStyle("paddingBottom", 3);
			statusLabel.setStyle("fontSize", 14);
			statusLabel.percentWidth = 100;
			statusLabel.text = "status: init";
			statusLabel.bottom = 0;
			statusLabel.left = 0;
			statusLabel.height = 20;
			
			//init child minimize AppButton
			minimizeButton.right = 25;
			minimizeButton.height = 20;
			minimizeButton.width = 20;
			minimizeButton.height = 20;
			minimizeButton.top = -27;
			minimizeButton.source = "assets/img/icons/minimize.png";
			minimizeButton.addEventListener(MouseEvent.MOUSE_UP, onMinimize);
			
			//init child resize AppButton
			resizeButton.right = 0;
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
		
		public function set status(msg:String):void{
			//set text in status label of child
			statusLabel.text = "status: " + msg;
		}
		
		public function get status():String{
			//return status text
			return statusLabel.text;
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
			
			this.invalidateDisplayList();
			this.invalidateSize();
		}
		
		protected function onResizeStop(event:MouseEvent):void {				
			//remove move handlers
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onResize);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onResizeStop);			
		}
		
		private function onClose(event:Event):void {
			close();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight-this.statusLabel.height);
		}
		
		//override add Element functions, so content is placed in content
		override public function addElement(element:IVisualElement):IVisualElement{
			return content.addElement(element);
		}
		
		override public function addElementAt(element:IVisualElement, position:int):IVisualElement{
			return content.addElementAt(element, position);
		}
	}
}