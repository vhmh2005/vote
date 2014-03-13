package  {
	import data.RTMPCommunicator;
	import display.VideoBox.VideoBox;
	import display.VideoBox.VideoMain;
	import display.VideoBox.VideoQueue;
	import events.RTMPCommunicatorEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Adrian R
	 */
	public class Main extends MovieClip {
		include "trace_implementation.as";
		
		private var nWidth:Number = 640;
		private var nHeight:Number = 530;
		private var arVideos:Array;
		private var txtStatus:TextField;
		
		private var spQueue:Sprite;
		
		private var oCommunicator:RTMPCommunicator;
		
		public function Main() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(evt:Event):void {
			ExternalInterface.addCallback("onConnectedToChat", onConnectedToChat);
			ExternalInterface.addCallback("onUpdateQueue", onUpdateQueue);
			
			oCommunicator = RTMPCommunicator.getInstance();
			oCommunicator.configure(root.loaderInfo.parameters);
			oCommunicator.addEventListener(RTMPCommunicatorEvent.CONNECTION_READY, onConnectionReady);
			oCommunicator.addEventListener(RTMPCommunicatorEvent.CONNECTION_CLOSED, onConnectionClosed);
			buildInterface();
		}
		
		private function buildInterface():void {
			txtStatus = new TextField();
			txtStatus.antiAliasType = AntiAliasType.ADVANCED;
			txtStatus.embedFonts = true;
			txtStatus.defaultTextFormat = new TextFormat(new VAGRound().fontName, 40, 0x000000, false, false, false, null, null, TextFormatAlign.CENTER);
			txtStatus.selectable = false;
			txtStatus.width = nWidth;
			txtStatus.text = "Connecting to video server...";
			txtStatus.height = txtStatus.textHeight + 4;
			txtStatus.x = 0;
			txtStatus.y = (nHeight - txtStatus.height) / 2 - 100;
			addChild(txtStatus);
			
			
			arVideos = new Array();
			
			var vid:VideoBox;
			vid = new VideoMain();
			addChild(vid);
			arVideos.push(vid);
			
			var nOffsetY:Number = vid.height;
			spQueue = new Sprite();
			spQueue.y = nOffsetY;
			addChild(spQueue);
			
			var i:int;
			for (i = 0; i < 4; i++ ) {
				vid = new VideoQueue();
				vid.x = i * vid.width;
				spQueue.addChild(vid);
				arVideos.push(vid);
			}
			
			externalOnLoaded();
		}
		
		// Events
		private function onConnectionReady(evt:RTMPCommunicatorEvent):void {
			externalOnConnected();
		}
		
		private function onConnectionClosed(evt:RTMPCommunicatorEvent):void {
			
		}
		
		
		// ExternalInterface -> Flash Calls
		public function onConnectedToChat(oCurrentUser:Object):void {
			trace("oCurrentUser " + oCurrentUser.username);
			oCommunicator.connect(oCurrentUser);
		}
		
		public function onUpdateQueue(arUsers:Array):void {
			trace("onUpdateQueue " + arUsers +" "+arUsers.length);
			if (arUsers.length) {
				txtStatus.text = "";
			}else {
				txtStatus.text = "Waiting for speakers...";
			}
			
			// publish
			var oCurrentUserInQueue:Object = null;
			var i:int;
			for (i = 0; i < arUsers.length; i++  ) {
				if (arUsers[i].id == oCommunicator.currentUser.id) {
					oCurrentUserInQueue = arUsers[i];
				}
			}
			if (oCurrentUserInQueue) {
				oCommunicator.publish(oCurrentUserInQueue.status == "speaking");
			}else {
				oCommunicator.unpublish();
			}
			
			
			// subscribe
			for (i = arUsers.length; i < arVideos.length; i++  ) {
				arUsers.push(null);
			}
			
			var arId:Array = new Array();
			for (i = 0; i < arVideos.length; i++  ) {
				arVideos[i].user = arUsers[i];
				if (arUsers[i] && (oCurrentUserInQueue == null || arUsers[i].id != oCurrentUserInQueue.id)) {
					arId.push(arUsers[i].id);
				}
			}
			
			oCommunicator.clearExtraNsIn(arId);
		}
		
		// Flash -> ExternalInterface Calls
		private function externalOnLoaded():void {
			ExternalInterface.call("chat.onFlashLoaded");
		}
		
		private function externalOnConnected():void {
			ExternalInterface.call("chat.onFlashConnected");
		}
	}

}