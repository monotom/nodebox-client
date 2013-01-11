package m.ui {
	/**
	 * An extension of the spark.components.TitleWindow for handling window resizing, minimizing and displaying.
	 * 
	 * @author Tom Hanoldt
	 */
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import m.ui.components.Button;
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import spark.components.Group;
	import spark.components.Scroller;
	import spark.components.TitleWindow;

	public class ChildWindow extends TitleWindow{
		public var minimizeButton:Button = new Button();
		public var resizeButton:Button   = new Button();
		public var content:Group 		 = new Group();
		
		private var oldHeight:Number;
		private var oldWidth:Number;
		private var oldX:Number;
		private var oldY:Number;
		private var oldMouseX:Number;
		private var oldMouseY:Number;
		
		/** 
		 * Constructor
		 */
		public function ChildWindow(){
			super();	
			minHeight = 150;
		}
		
		/** 
		 * This method displays the window inside an application.
		 * 
		 * @param parent The parent of the window on which the child window appear. If null the toplevel application is used.
		 * @param center Indicates weather to center the window inside the parent or not.
		 * @param model Set the window as modal or not.
		 */
		public function show(parent:DisplayObject = null, center:Boolean = true, modal:Boolean = false):void {
			if (parent == null)
				parent = FlexGlobals.topLevelApplication as DisplayObject;	
				
			PopUpManager.addPopUp(this, parent, modal);
			if (center)
				PopUpManager.centerPopUp(this);
		}
		
		/** 
		 * This method closes the window.
		 * 
		 * @return void
		 */
		public function close():void {
			PopUpManager.removePopUp(this);
		}
		
		[ArrayElementType("mx.core.IVisualElement")]
		/** 
		 * This method is used to add mxml components to the window if a mxml component was extended.
		 */
		override public function set mxmlContent(value:Array):void {
			_mxmlContent = value;
		}
		private var _mxmlContent:Array;

		private var scroller:Scroller = new Scroller();
		/** 
		 * This method is called when the window children will be created.
		 * Here are the mxml components added to the window.
		 * 
		 * @return void
		 */
		override protected function createChildren():void {			
			super.createChildren();
			
			if( _mxmlContent != null ) {
				for (var i:int = 0; i < _mxmlContent.length; i++) {   
					var elt:IVisualElement = _mxmlContent[i];
					addElement(elt);
				}
			}
			
			scroller.width = width;
			scroller.height = height;
			scroller.viewport = content;
			super.addElement(scroller);

			setStyle("cornerRadius", 10);
			
			//init child minimize AppButton
			minimizeButton.right = 25;
			minimizeButton.height = 20;
			minimizeButton.width = 20;
			minimizeButton.height = 20;
			minimizeButton.top = -27;
			minimizeButton.source = "assets/img/icons/minimize.png";
			minimizeButton.addEventListener(MouseEvent.MOUSE_UP, onMinimize);
			super.addElement(minimizeButton);
			
			//init child resize AppButton
			resizeButton.right = scroller.verticalScrollBar.visible ? 10 : 0;
			resizeButton.height = 20;
			resizeButton.width = 20;
			resizeButton.height = 20;
			resizeButton.bottom = 0;
			resizeButton.source = "assets/img/icons/resize.png";
			resizeButton.addEventListener(MouseEvent.MOUSE_DOWN, onResizeStart);
			super.addElement(resizeButton);
			
			//init child close AppButton
			addEventListener(CloseEvent.CLOSE, onClose);
		}
		
		/** 
		 * This method adds a event listener for closing event of this window.
		 * 
		 * @return void
		 */
		public function addOnClose(callback:Function):void {
			addEventListener(CloseEvent.CLOSE, callback);
		}
		
		/** 
		 * This method thets the window title
		 * 
		 * @param title The new Title.
		 * 
		 * @return void.
		 */
		override public function set title(title:String):void{
			//set title of child window
			super.title = '        ' + title; 
		}
			
		/** 
		 * This method returns the window title.
		 * 
		 * @return The window Title.
		 */
		override public function get title():String{
			//strip window title and return
			return super.title ? super.title.replace(/^\s+|\s+$/gs, '') : ""; 
		}
		
		/** 
		 * This method called when the window should minimize.
		 * 
		 * @param event The mouse event initiated the minimizing.
		 * 
		 * @return void
		 */
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
		
		/** 
		 * This method is called if the window should unminimize.
		 * 
		 * @param event The mouse event which initated the unminimizing.
		 * @param doHeight Indicates if to restore the old window height.
		 * 
		 * @return void 
		 */
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
		
		/** 
		 * This method is called qhen resizing of window starts.
		 * 
		 * @param event The mouse event which initated the resizing.
		 * 
		 * @return void
		 */
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
		
		/** 
		 * This method is called while resizing the window and sets the actual bounds.
		 * 
		 * @param event The mouse event.
		 * 
		 * @return void
		 */
		protected function onResize(event:MouseEvent):void {
			//set new height and width with relative mouse coords
			width  = width  - (oldMouseX - event.stageX);
			height = height - (oldMouseY - event.stageY);		
			
			//store last mouse positions
			oldMouseX = event.stageX;
			oldMouseY = event.stageY;
		}
		
		/** 
		 * This method is called when resizing is finished.
		 * 
		 * @param event The mouse event.
		 *
		 * @return void
		 */
		protected function onResizeStop(event:MouseEvent):void {				
			//remove move handlers
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onResize);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onResizeStop);			
		}
		
		/** 
		 * This method is called on window close.
		 * 
		 * @param event The mouse event.
		 */
		private function onClose(event:Event):void {
			close();
		}
		
		/** 
		 * This method is called when the display list of the window is updated.
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight+18);
			scroller.width = width;
			scroller.height = height;
			resizeButton.right = scroller.verticalScrollBar.visible ? 10 : 0;
		}
		
		/** 
		 * override add Element functions, so childs are added to the wrapped content
		 * 
		 * @param element The element to add
		 * 
		 * @return the added element.
		 */
		override public function addElement(element:IVisualElement):IVisualElement {
			return content.addElement(element);
		}
		
		/** 
		 * override add Element functions, so childs are added to the wrapped content
		 * 
		 * @param element The element to add
		 * 
		 * @return the added element.
		 */
		override public function addElementAt(element:IVisualElement, position:int):IVisualElement{
			return content.addElementAt(element, position);
		}
	}
}