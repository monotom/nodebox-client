package m.nodebox.ui.viewer
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import sd.app.DesktopElement;
	import sd.app.SharedDesktop;
	import sd.ui.ChildWindowClass;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	
	/**
	 * This class represents the context ItemDialog for the delete of a DesktopElement.
	 * @autor ChallengerCC
	 */
	
	public class DeleteItemDialog extends ChildWindowClass
	{
		private var desktopElement:DesktopElement;
		private var sharedDesktop:SharedDesktop;
		
		public function DeleteItemDialog(sharedDesktop:SharedDesktop, desktopElement:DesktopElement):void
		{
			super();
			this.sharedDesktop = sharedDesktop;
			
			if(desktopElement == null){
				this.desktopElement = new DesktopElement();
			}else{
				this.desktopElement = desktopElement;
			}
			
			this.title = "Delete DesktopItem";
			
			var infoName:Label = new Label();
			infoName.text="Soll dieses DesktopItem gelöscht werden?";
			infoName.setStyle("paddingTop","20");
			infoName.setStyle("paddingRight","20");
			infoName.setStyle("paddingLeft","20");
			infoName.setStyle("paddingBottom","20");
						
			var yesButton:Button = new Button();
			yesButton.label="Yes";
			yesButton.addEventListener(MouseEvent.MOUSE_UP, deleteDesktopElement);
			yesButton.x = 50;
			yesButton.y = 60;
			
			var noButton:Button = new Button();
			noButton.label="No";
			noButton.addEventListener(MouseEvent.MOUSE_UP, closeContextMenu);
			noButton.x = 150;
			noButton.y = 60;
			
			addElement(infoName);			
			addElement(yesButton);
			addElement(noButton);			
		}
		
		private function closeContextMenu(e:MouseEvent):void
		{
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function deleteDesktopElement(e:MouseEvent):void
		{
			sharedDesktop.deleteDesktopElement(desktopElement);
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
}