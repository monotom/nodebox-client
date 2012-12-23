package m.ui{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import mx.core.IVisualElement;
	import spark.components.Button;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class Notice extends ChildWindow{
		public function Notice() {
			super();
			minimizeButton.visible = false;
		}
		
		public var closeButton2:Button = new Button();
		override protected function createChildren():void {
			super.createChildren();
			
			closeButton2.label = 'OK';
			closeButton2.bottom = 3;
			closeButton2.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
				close();
			});
			
			addElement(closeButton2);
		}
		
		//TODO doesnt work
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight - closeButton2.height);
		}
	}
}