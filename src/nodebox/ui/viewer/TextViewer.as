package nodebox.ui.viewer
{
	import sd.app.DesktopElement;
	import sd.ui.ChildWindowClass;

	public class TextViewer extends ChildWindowClass
	{
		private var desktopElement:DesktopElement;
		
		public function TextViewer(desktopElement:DesktopElement):void
		{
			this.desktopElement = desktopElement;
		}
	}
}