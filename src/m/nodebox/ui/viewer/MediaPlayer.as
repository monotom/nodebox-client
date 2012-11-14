package m.nodebox.ui.viewer
{
	import sd.app.DesktopElement;
	import sd.ui.ChildWindowClass;

	public class MediaPlayer extends ChildWindowClass
	{
		private var desktopElement:DesktopElement;
		
		//TODO http://blog.flexexamples.com/2008/03/01/displaying-a-video-in-flex-using-the-netconnection-netstream-and-video-classes/
		public function MediaPlayer(desktopElement:DesktopElement):void
		{
			this.desktopElement = desktopElement;
		}
	}
}