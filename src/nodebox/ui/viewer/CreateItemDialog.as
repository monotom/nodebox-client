package nodebox.ui.viewer
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import sd.app.DesktopElement;
	import sd.app.SharedDesktop;
	import sd.ui.ChildWindowClass;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.components.VGroup;
	
	/**
	 * This class represents the context ItemDialog for the creation of a DesktopElement.
	 * 
	 */
	
	public class CreateItemDialog extends ChildWindowClass
	{
		private var desktopElement:DesktopElement;
		private var sharedDesktop:SharedDesktop;
		private var textInput1:TextInput;
		private var textInput2:TextInput;
		
		public function CreateItemDialog(sharedDesktop:SharedDesktop, desktopElement:DesktopElement=null):void
		{
			super();
			this.sharedDesktop = sharedDesktop;
			
			var createItemText:String = 'Create';
			if(desktopElement == null){
				this.desktopElement = new DesktopElement();
			}else{
				this.desktopElement = desktopElement;
				createItemText = 'Update';
			}
										
			title = "Create/Update DesktopItem";
			
			var infoName:Label = new Label();
			infoName.text="Geben Sie einen Itemnamen an:";
			
			textInput1 = new TextInput();
			textInput1.text = this.desktopElement.vo.name;
			textInput1.x = 200;
			
			var infoURL:Label = new Label();
			infoURL.text="Geben Sie die URL ein:";
			infoURL.y = 30;
			
			textInput2 = new TextInput();
			textInput2.text = this.desktopElement.vo.resourceUrl;
			textInput2.y = 30;
			textInput2.x = 200;
			
			var createButton:Button = new Button();
			createButton.label=createItemText;
			createButton.addEventListener(MouseEvent.MOUSE_UP, createDesktopElement);
			createButton.y = 70;
			createButton.x = 0;
			
			var closeButton:Button = new Button();
			closeButton.label="Close";
			closeButton.addEventListener(MouseEvent.MOUSE_UP, closeContextMenu);
			closeButton.y = 70;
			closeButton.x = 90;
			
			addElement(infoName);
			addElement(textInput1);
			addElement(infoURL);
			addElement(textInput2);
			addElement(createButton);
			addElement(closeButton);
		}
		
		public function getDesktopElement():DesktopElement
		{
			return desktopElement;			
		}			
		
		private function closeContextMenu(e:MouseEvent):void
		{
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function createDesktopElement(e:MouseEvent):void
		{
			this.desktopElement.vo.name = textInput1.text;
			this.desktopElement.vo.resourceUrl = textInput2.text;
			sharedDesktop.addDesktopElement(desktopElement);
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
}