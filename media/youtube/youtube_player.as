/**
 * Creates a managable wrapper for the Youtube API.
 *
 * Usage {{{
 *    var player:youtube_player = new youtube_player();
 *    addChild(player);
 *    player.addEventListener(youtube_player.PLAYER_READY,
 *    	function(e:custom_event):void {
 *    		player.loadVideoByUrl("http://www.youtube.com/v/E_7o986jF3s");
 *    	},
 *    	false
 *    );
 * }}}
 */

package classes.media.youtube {
	import classes.events.custom_event;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.Security;
	
	public class youtube_player extends MovieClip {
		// setup the security configuration
		Security.allowDomain("www.youtube.com");
		Security.allowDomain("youtube.com");
		Security.allowDomain("s.ytimg.com");
		Security.allowDomain("i.ytimg.com");
		
		// Global vars
		public static var PLAYER_ERROR:String			= new String("onError");
		public static var PLAYER_READY:String			= new String("onReady");
		public static var PLAYER_STATE_CHANGE:String	= new String("onStateChange");
		public static var VIDEO_UNSTARTED:Number		= -1;
		public static var VIDEO_ENDED:Number			= 0;
		public static var VIDEO_PLAYING:Number			= 1;
		public static var VIDEO_PAUSED:Number			= 2;
		public static var VIDEO_BUFFERING:Number		= 3;
		public static var VIDEO_CUED:Number				= 5;
		private var _currentState:Number				= VIDEO_UNSTARTED;						// flag to indicate the current state
		private var _currentVideo:String				= null;									// flag to indicate the current video loaded
		private var _loader:Loader						= null;									// loader object that loads the player
		private var _player:Object						= null;									// reference to the loaded youtube player
		private var _playerReady:Boolean				= false;								// flag to indicate if the player is ready
		
		/**
		 * constructor: sets up the youtube_player
		 */
		public function youtube_player():void {
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.INIT, _loaderInitialized, false);
			_loader.load(new URLRequest("http://www.youtube.com/apiplayer?version=3"));
		}
		
		/**
		 * loads the specified video's thumbnail and prepares the player to play the video
		 */
		public function cueVideoById(videoId:String, startSeconds:Number=0, suggestedQuality:String="default"):void {
			if ((_player != null) && (_currentVideo != videoId)) {
				_currentVideo = videoId;
				_player.cueVideoById(videoId, startSeconds, suggestedQuality);
			}
		}
		
		/**
		 * loads the specified video's thumbnail and prepares the player to play the video
		 */
		public function cueVideoByUrl(mediaContentUrl:String, startSeconds:Number=0):void {
			if ((_player != null) && (_currentVideo != mediaContentUrl)) {
				_currentVideo = mediaContentUrl;
				_player.cueVideoByUrl(mediaContentUrl, startSeconds);
			}
		}
		
		/**
		 * destroys the player instance
		 */
		public function destroy():void {
			if (_player != null) {
				// destroy the youtube player
				_player.removeEventListener(PLAYER_READY,			_onPlayerReady,			false);
				_player.removeEventListener(PLAYER_ERROR,			_onPlayerError,			false);
				_player.removeEventListener(PLAYER_STATE_CHANGE,	_onPlayerStateChange,	false);
				_player.destroy();
				_player = null;
			}
			if (_loader != null) {
				// close/unload the loader
				_loader.close();
				_loader.unload();
				_loader = null;
			}
		}
		
		/**
		 * returns the set of quality formats in which the current video is available
		 */
		public function getAvailableQualityLevels():Array {
			return (_player != null) ? _player.getAvailableQualityLevels() : new Array("default");
		}
		
		/**
		 * returns the elapsed time in seconds since the video started playing
		 */
		public function getCurrentTime():Number {
			return (_player != null) ? _player.getCurrentTime() : 0;
		}
		
		/**
		 * returns the duration in seconds of the current video
		 */
		public function getDuration():Number {
			return (_player != null) ? _player.getDuration() : 0;
		}
		
		/**
		 * returns the current playback quality of the player
		 */
		public function getPlaybackQuality():String {
			return (_player != null) ? _player.getPlaybackQuality() : "default";
		}
		
		/**
		 * returns the state of the player
		 */
		public function getPlayerState():Number {
			return (_player != null) ? _player.getPlayerState() : -1;
		}
		
		/**
		 * returns the number of bytes loaded for the current video
		 */
		public function getVideoBytesLoaded():Number {
			return (_player != null) ? _player.getVideoBytesLoaded() : 0;
		}
		
		/**
		 * returns the size in bytes of the current video
		 */
		public function getVideoBytesTotal():Number {
			return (_player != null) ? _player.getVideoBytesTotal() : 0;
		}
		
		/**
		 * returns the embed code for the video
		 */
		public function getVideoEmbedCode():String {
			return (_player != null) ? _player.getVideoEmbedCode() : "";
		}
		
		/**
		 * returns the number of bytes the video started loading from
		 */
		public function getVideoStartBytes():Number {
			return (_player != null) ? _player.getVideoStartBytes() : 0;
		}
		
		/**
		 * returns the www.youtube.com URL for the current video
		 */
		public function getVideoUrl():String {
			return (_player != null) ? _player.getVideoUrl() : "";
		}
		
		/**
		 * returns the volume setting for the video
		 */
		public function getVolume():Number {
			return (_player != null) ? _player.getVolume() : 0;
		}
		
		/**
		 * checks whether or not the volume is muted
		 */
		public function isMuted():Boolean {
			return (_player != null) ? _player.isMuted() : true;
		}
		
		/**
		 * indicates if the player is ready or not
		 */
		public function isPlayerReady():Boolean {
			return _playerReady;
		}
		
		/**
		 * loads and plays the specified video
		 */
		public function loadVideoById(videoId:String, startSeconds:Number=0, suggestedQuality:String="default"):void {
			if ((_player != null) && (_currentVideo != videoId)) {
				_currentVideo = videoId;
				_player.loadVideoById(videoId, startSeconds, suggestedQuality);
			}
		}
		
		/**
		 * loads and plays the specified video
		 */
		public function loadVideoByUrl(mediaContentUrl:String, startSeconds:Number=0):void {
			if ((_player != null) && (_currentVideo = mediaContentUrl)) {
				_currentVideo = mediaContentUrl;
				_player.loadVideoByUrl(mediaContentUrl, startSeconds);
			}
		}
		
		/**
		 * mute the volume of the video
		 */
		public function mute():void {
			if (_player != null) _player.mute();
		}
		
		/**
		 * pause the video
		 */
		public function pauseVideo():void {
			if (_player != null) _player.pauseVideo();
		}
		
		/**
		 * start playing the video
		 */
		public function playVideo():void {
			if (_player != null) _player.playVideo();
		}
		
		/**
		 * seek to the specified number of seconds in the video
		 */
		public function seekTo(seconds:Number, allowSeekAhead:Boolean=false):void {
			if (_player != null) {
				_player.seekTo(seconds, allowSeekAhead);
			}
		}
		
		/**
		 * set the suggested playback quality of the video
		 */
		public function setPlaybackQuality(suggestedQuality:String):void {
			if (_player != null) _player.setPlaybackQuality(suggestedQuality);
		}
		
		/**
		 * set the size of the video
		 */
		public function setSize(width:Number, height:Number):void {
			if (_player != null) _player.setSize(width, height);
		}
		
		/**
		 * set the volume of the video
		 */
		public function setVolume(volume:Number):void {
			if (_player != null) _player.setVolume(volume);
		}
		
		/**
		 * stop the video
		 */
		public function stopVideo():void {
			if (_player != null) _player.stopVideo();
		}
		
		/**
		 * unmute the video player
		 */
		public function unMute():void {
			if (_player != null) _player.unMute();
		}
		
		/**
		 * listener for when the loader has initialized and then sets up the player listeners
		 */
		private function _loaderInitialized(e:Event):void {
			_loader.contentLoaderInfo.removeEventListener(Event.INIT, _loaderInitialized, false);
			addChild(_loader);
			
			_loader.content.addEventListener(PLAYER_READY,			_onPlayerReady,			false);
			_loader.content.addEventListener(PLAYER_ERROR,			_onPlayerError,			false);
			_loader.content.addEventListener(PLAYER_STATE_CHANGE,	_onPlayerStateChange,	false);
		}
		
		/**
		 * listener for when the player becomes ready
		 */
		private function _onPlayerReady(e:Event):void {
			trace("[youtube_player] The player is now ready.");
			
			// store the reference to the video player (so we don't have to keep referencing loader.content)
			_player = _loader.content;
			
			// set the default properties for the video player (these can be changed at any time!)
			setSize(480, 360);
			setPlaybackQuality("default");

			// dispatch to let the rest of the world know the player is ready
			dispatchEvent(new custom_event(PLAYER_READY, e));
			_playerReady = true;
		}
		
		/**
		 * listener for when the player encounters an error
		 */
		private function _onPlayerError(e:Event):void {
			var code:Number	= Number(Object(e).data);
			var msg:String	= new String((code == 100) ? "The requested video was not found." : "The requested video does not allow playback in embedded players.");
			trace("[youtube_player] Error: " + code + "; " + msg);
			
			// dispatch the error to any available listeners
			dispatchEvent(new custom_event(PLAYER_ERROR, {code: code, message: msg}));
		}
		
		/**
		 * listener for when the state of the player changes
		 */
		private function _onPlayerStateChange(e:Event):void {
			var state:Number = Number(Object(e).data);
			if (state == _currentState) return;
			_currentState = state;
			trace("[youtube_player] The player's state has changed to: " + state);
			
			// dispatch the state change to any available listeners
			dispatchEvent(new custom_event(PLAYER_STATE_CHANGE, {state: state}));
		}
	}
}