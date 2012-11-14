package m.nodebox.ui.viewer
{
	import sd.app.DesktopElement;
	import sd.ui.ChildWindowClass;

	public class ImageViewer extends ChildWindowClass
	{
		private var desktopElement:DesktopElement;
		
		public function ImageViewer(desktopElement:DesktopElement):void
		{
			this.desktopElement = desktopElement;
		}
	}
}