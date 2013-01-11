package m.ui{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import spark.components.Button;
	import spark.components.TextArea;
	/**
	 * Extend the child window class for a simple notice window with a simple message label and a extra close button. @see ChildWindow
	 * 
	 * @author Tom Hanoldt
	 */
	public class Notice extends ChildWindow{
		/** 
		 * Constructor.
		 * 
		 * @param width The width of the notice box.
		 * @param height The height of the notice box.
		 */
		public function Notice(width:int = 250, height:int = 300) {
			super();
			this.width = width;
			this.height = height;
			minimizeButton.visible = false;
			resizeButton.visible = true;
		}
		
		public var closeButton2:Button = new Button();
		public var label:TextArea = new TextArea();
		/** 
		 * This method overrides the parent createChildren method for adding the label and the close button.
		 */
		override protected function createChildren():void {
			super.createChildren();
			
			closeButton2.label = 'OK';
			closeButton2.bottom = 3;
			closeButton2.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
				close();
			});
			
			addElement(closeButton2);
			
			addElement(label);
			label.width = width;
			label.height = height - closeButton.height - 10;
			
		}
	}
}