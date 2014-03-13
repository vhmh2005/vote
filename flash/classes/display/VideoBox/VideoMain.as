package display.VideoBox {
	import display.LibraryButton;
	import display.ShapeButton;
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import org.computus.model.Timekeeper;
	import org.computus.model.TimekeeperEvent;
	/**
	 * ...
	 * @author Adrian R
	 */
	public class VideoMain extends VideoBox {
		include "../../trace_implementation.as";
		
		private var txtTime:TextField;
		
		private var btnThumbUp:LibraryButton;
		private var btnThumbDown:LibraryButton;
		private var btnFavorite:LibraryButton;
		private var btnUnfavorite:LibraryButton;
		private var btnFullscreen:LibraryButton;
		private var btnExitFullscreen:LibraryButton;
		
		private var spVolume:Sprite;
		
		private var timekeeper:Timekeeper;
		
		public function VideoMain() {
			super(640, 420);
		}
		
		override protected function buildInterface():void {
			trace("VideoMain buildInterface");
			txtTime = new TextField();
			txtTime.antiAliasType = AntiAliasType.ADVANCED;
			txtTime.embedFonts = true;
			txtTime.defaultTextFormat = new TextFormat(new VAGRound().fontName, 14, 0x000000, false, false, false, null, null, TextFormatAlign.LEFT);
			txtTime.selectable = false;
			txtTime.width = 200;
			txtTime.text = "Remaining 99:99";
			txtTime.height = txtTime.textHeight + 4;
			txtTime.x = 2;
			txtTime.y = (20 - txtTime.height) / 2;
			addChild(txtTime);
			
			buidVideo(0, 20, nWidth, 360);
			
			timekeeper = new Timekeeper();
			timekeeper.addEventListener( TimekeeperEvent.CHANGE, onTick );
			timekeeper.setValue(0);
			timekeeper.setRealTimeTick();
			timekeeper.startTicking();
		}
		
		override public function set user(oUser:Object):void {
			var bUpdateTime:Boolean = false;
			if (oUser) {
				if (this.oUser && this.oUser.id == oUser.id) {
					if (this.oUser.time != oUser.time) {
						bUpdateTime = true;
					}
				}else {
					bUpdateTime = true;
				}
			}
			
			super.user = oUser;
			
			if (bUpdateTime) {
				timekeeper.stopTicking();
				timekeeper.setValue(0);
				timekeeper.startTicking();
			}
		}
		
		public function onTick(evt:TimekeeperEvent=null):void {
			trace("onTick " + oUser);
			if(oUser){
				var dif:Number = oUser.time - timekeeper.getValue()/1000;
				
				if (dif >= 0) {
					txtTime.text = "Remaining ";
					
					var mins:Number = Math.floor( dif / 60 );  
					dif -= mins * 60;   
					var sec:Number = Math.floor(dif);           
					   
					txtTime.appendText(((mins.toString().length == 1) ? "0" + mins : mins).toString()+":");
					txtTime.appendText(((sec.toString().length == 1) ? "0" + sec : sec).toString());   
				}
			}
		}
		
	}

}