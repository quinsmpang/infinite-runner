package soundpatchdemo {

	import citrus.core.CitrusEngine;
	
	import soundpatchdemo.DemoState;
	import soundpatchdemo.WebsiteFrame;

	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	[SWF(backgroundColor="#000000", frameRate="60", width="940", height="410")]

	public class Main extends CitrusEngine {

		public function Main() {

			// Create audio assets
			sound.addSound("Collect", "sounds/collect.mp3");
			sound.addSound("Hurt", "sounds/hurt.mp3");
			sound.addSound("Jump", "sounds/jump.mp3");
			sound.addSound("Kill", "sounds/kill.mp3");
			sound.addSound("Skid", "sounds/skid.mp3");
			sound.addSound("Song", "sounds/song.mp3");
			sound.addSound("Walk", "sounds/walk.mp3");

			var loader:Loader = new Loader();
			loader.load(new URLRequest("levels/SoundPatchDemo/SoundPatchDemo.swf"));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleSWFLoadComplete, false, 0, true);

			var websiteFrame:WebsiteFrame = new WebsiteFrame();
			addChild(websiteFrame);
		}

		private function handleSWFLoadComplete(e:Event):void {
			var levelObjectsMC:MovieClip = e.target.loader.content;
			state = new DemoState(levelObjectsMC);

			e.target.loader.unloadAndStop();
		}
	}
}