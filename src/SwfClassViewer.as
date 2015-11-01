package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	import starling.core.Starling;
	import client.Viewer;
	
	[SWF(width="800", height="600", frameRate="24", backgroundColor="#ffffff")]
	public class SwfClassViewer extends Sprite
	{		
		private var _starling:Starling = null;
		
		public function SwfClassViewer()
		{
			stage ? initialize():addEventListener(Event.ADDED_TO_STAGE, function (event:Event) : void {
				event.target.removeEventListener(Event.ADDED_TO_STAGE, arguments.callee);
				initialize();
			});
		}
		
		private function initialize() : void
		{			
			_starling = new Starling(Viewer, stage);
			_starling.start();
			_starling.showStats = true;
			_starling.antiAliasing = 2;
		}
	}
}