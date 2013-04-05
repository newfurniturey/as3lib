/**
 * Creates a multi-class wrapper to handle a YouTube player, playlist, and video controls.
 *
 * Usage {{{
 *    var youtube:youtube_wrapper = new youtube_wrapper(settings); // 'settings' is an object will all required settings specified
 *    youtube.addEventListener(youtube_wrapper.YOUTUBE_READY, _youtubeReady, false);
 *    function _youtubeReady(e:custom_event):void {
 *    	// controls
 *    	addChild(e.params.controls);
 *    	e.params.controls.x = 5;
 *    	e.params.controls.y = 370;
 *    	// playlist
 *    	addChild(e.params.playlist);
 *    	e.params.playlist.x = (stage.stageWidth - settings.playlist.itemWidth);
 *    	// player
 *    	addChild(e.params.player);
 *    	// load a playlist
 *    	youtube.loadPlayist("http://gdata.youtube.com/feeds/api/users/watchtheguild/playlists");
 *    }
 * }}}
 */

package classes.media.youtube {
	import classes.controls.video.video_controls;
	import classes.events.custom_event;
	import classes.media.youtube.youtube_player;
	import classes.media.youtube.youtube_playlist;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class youtube_wrapper extends Sprite {
		// Global vars
		public static var PLAYLIST_READY:String		= new String("playlistReady");
		public static var YOUTUBE_READY:String		= new String("youtubeReady");
		private var _controls:video_controls		= null;										// Controls
		private var _currentState:Number			= -1;										// holds the current state of the video player
		private var _isReady:Boolean				= false;									// flag to indicate if the wrapper is ready or not
		private var _player:youtube_player			= null;										// YouTube player
		private var _playlist:youtube_playlist		= null;										// Playlist
		private var _playlistJustLoaded:Boolean		= false;									// flag to indicate if a playlist just loaded (to ignore the "play" selection)
		private var _playVideo:String				= null;										// temporary flag to indicate what video to load
		private var _playVideoAutoStart:Boolean		= false;									// temporary flag to indicate whether or not to auto-play the video
		private var _playVideoIsId:Boolean			= false;									// temporary flag to indicate if the video is an ID or URL
		private var _settings:Object				= null;										// global object to hold all of the wrapper's settings
		private var _setupLevel:int					= 0;										// flag to indicate the current setup level we're on
		
		/**
		 * constructor: sets up the youtube_wrapper
		 */
		public function youtube_wrapper(settings:Object):void {
			_processSettings(settings);
			
			_setup();
		}
		
		/**
		 * loads the specified playlist
		 */
		public function loadPlaylist(playlistUrl:String):void {
			if (!_isReady) return;
			
			if (_playlist == null ) {
				trace("[youtube_wrapper] There is no loaded playlist.");
				return;
			}
			
			_playlist.load(playlistUrl);
		}
		
		/**
		 * plays the specified video
		 */
		public function play(videoUrl:String, isId:Boolean=false, autoStart:Boolean=false):void {
			if (!_isReady) return;
			
			_playVideo = videoUrl;
			_playVideoIsId = isId;
			_playVideoAutoStart = autoStart;
			if (_player.isPlayerReady()) {
				_play(_playVideo, isId, autoStart);
				_playVideo = null;
			}
		}
		
		/**
		 * sets the player's width and height
		 */
		public function setPlayerSize(width:Number, height:Number):void {
			if (!_isReady) return;
			_player.setSize(width, height);
		}
		
		/**
		 * unselects all of the playlist items
		 */
		public function unselectPlaylistItem():void {
			if (!_isReady || (_playlist == null)) return;
			//_play("", false, false); // we need to "play" an empty movie so that, if the current video is selected again, the state 5 (cued) is thrown again
			//_player.stopVideo();
			_playlist.deselectAll();
		}
		
		/**
		 * checks the current bufferered percentage to update the video controls
		 */
		private function _checkVideoBufferStatus(e:Event):void {
			if (_player != null) {
				var loaded:Number = _player.getVideoBytesLoaded();
				var total:Number = _player.getVideoBytesTotal();
				if (loaded >= total) {
					_controls.updateBuffer(1);
					removeEventListener(Event.ENTER_FRAME, _checkVideoBufferStatus, false);
				} else {
					_controls.updateBuffer((loaded / total));
				}
			}
		}
		
		/**
		 * checks the current position of the playhead to update the video_controls
		 */
		private function _checkVideoPlayStatus(e:Event):void {
			if (_player != null) {
				var played:Number = _player.getCurrentTime();
				var total:Number = _player.getDuration();
				
				_controls.setCurrentTime(played);
				_controls.setDuration(total);
				if (played >= total) {
					_controls.seekTo(1);
					removeEventListener(Event.ENTER_FRAME, _checkVideoPlayStatus, false);
				} else {
					_controls.seekTo((played / total));
				}
			}
		}
		
		/**
		 * listener for the fullscreen control button
		 */
		private function _controlsFullscreen(e:custom_event):void {
			trace("[youtube_wrapper] Fullscreen. Not yet implemented.");
		}
		
		/**
		 * listener for the next control button
		 */
		private function _controlsNext(e:custom_event):void {
			trace("[youtube_wrapper] Next.");
			if (_playlist == null) return;
			_playlist.next();
		}
		
		/**
		 * listener for the pause control button
		 */
		private function _controlsPause(e:custom_event):void {
			trace("[youtube_wrapper] Pause.");
			_player.pauseVideo();
		}
		
		/**
		 * listener for the play control button
		 */
		private function _controlsPlay(e:custom_event):void {
			trace("[youtube_wrapper] Play.");
			_player.playVideo();
		}
		
		/**
		 * listener for the previous control button
		 */
		private function _controlsPrevious(e:custom_event):void {
			trace("[youtube_wrapper] Previous.");
			if (_playlist == null) return;
			_playlist.previous();
		}
		
		/**
		 * listens for when the video_controls are ready and then completes setup
		 */
		private function _controlsReady(e:custom_event):void {
			_controls.removeEventListener(video_controls.CONTROLS_READY, _controlsReady, false);
			
			// add all of the button/seek/volume listeners
			_controls.addEventListener(video_controls.VIDEO_FULLSCREEN,	_controlsFullscreen,	false, 0, true);
			_controls.addEventListener(video_controls.VIDEO_NEXT,		_controlsNext,			false, 0, true);
			_controls.addEventListener(video_controls.VIDEO_PAUSE,		_controlsPause,			false, 0, true);
			_controls.addEventListener(video_controls.VIDEO_PLAY,		_controlsPlay,			false, 0, true);
			_controls.addEventListener(video_controls.VIDEO_PREVIOUS,	_controlsPrevious,		false, 0, true);
			_controls.addEventListener(video_controls.VIDEO_SEEK,		_controlsSeek,			false, 0, true);
			_controls.addEventListener(video_controls.VIDEO_STOP,		_controlsStop,			false, 0, true);
			_controls.addEventListener(video_controls.VOLUME_CHANGE,	_controlsVolume,		false, 0, true);
		
			trace("[youtube_wrapper] The video controls have been setup.");
			_setupLevel++;
			_setup();
		}
		
		/**
		 * listener for the seek control
		 */
		private function _controlsSeek(e:custom_event):void {
			trace("[youtube_wrapper] Seek to: " + e.params.value);
			_player.seekTo(((e.params.value / 100) * _player.getDuration()), false);
		}
		
		/**
		 * listener for the stop control button
		 */
		private function _controlsStop(e:custom_event):void {
			trace("[youtube_wrapper] Stop.");
			_player.seekTo(0, false);
			_player.stopVideo();
		}
		
		/**
		 * listener for the volume control
		 */
		private function _controlsVolume(e:custom_event):void {
			trace("[youtube_wrapper] Volume to: " + e.params.value);
			_player.setVolume(e.params.value);
		}
		
		/**
		 * create and setup the video_controls object
		 */
		private function _createVideoControls():void {
			_controls = new video_controls(_settings.controls);
			_controls.addEventListener(video_controls.CONTROLS_READY, _controlsReady, false, 0, true);
		}
		
		/**
		 * create and setup the youtube_player object
		 */
		private function _createVideoPlayer():void {
			_player = new youtube_player();
			
			// add the listeners to the player
			_player.addEventListener(youtube_player.PLAYER_ERROR,			_playerError,		false);
			_player.addEventListener(youtube_player.PLAYER_READY,			_playerReady,		false);
			_player.addEventListener(youtube_player.PLAYER_STATE_CHANGE,	_playerStateChange,	false);
		}
		
		/**
		 * create and setup the youtube_playlist object
		 */
		private function _createVideoPlaylist():void {
			_playlist = new youtube_playlist(_settings.playlist);
			
			// add the listeners to the playlist
			_playlist.addEventListener(youtube_playlist.PLAYLIST_READY,		_playlistReady,		false);
			_playlist.addEventListener(youtube_playlist.PLAYLIST_SELECT,	_playlistSelect,	false);
			
			trace("[youtube_wrapper] The playlist has been setup.");
			_setupLevel++;
			_setup();
		}
		
		/**
		 * plays the specified video
		 */
		private function _play(videoUrl:String, isId:Boolean, autoStart:Boolean):void {
			if (_player.isPlayerReady()) {
				if (isId) {
					// we're using a video ID and not a URL
					autoStart ? _player.loadVideoById(videoUrl) : _player.cueVideoById(videoUrl);
				} else {
					// we're using a video URL
					autoStart ? _player.loadVideoByUrl(videoUrl) : _player.cueVideoByUrl(videoUrl);
				}
				dispatchEvent(new custom_event(youtube_player.PLAYER_STATE_CHANGE, {state: (autoStart ? youtube_player.VIDEO_PLAYING : youtube_player.VIDEO_CUED)}));
			}
		}
		
		/**
		 * listener for any player errors
		 */
		private function _playerError(e:custom_event):void {
			trace("[youtube_wrapper] Player Error: " + e.params.message);
			// not really implemented yet... could probably make this "customizable" though
			// off topic, im really in the mood for some of them Pillsbury Cinnamon Rolls (with icing, of course!... those orange-ish icing ones are pretty boss too!)
		}
		
		/**
		 * listener for when the player is ready to continue setup
		 */
		private function _playerReady(e:custom_event):void {
			trace("[youtube_wrapper] The player is now ready.");
			
			_setupLevel++;
			_setup();
		}
		
		/**
		 * processes the player-state-changing events
		 */
		private function _playerStateChange(e:custom_event):void {
			// this function intertwines the player and controls, so if the controls are not setup there isn't anything to do!
			if (_controls == null) return;

			switch (e.params.state) {
				case youtube_player.VIDEO_UNSTARTED:
					if (_currentState == youtube_player.VIDEO_PLAYING) {
						removeEventListener(Event.ENTER_FRAME, _checkVideoPlayStatus, false);
						_controls.stop();
						_controls.seekTo(0);
						_controls.setCurrentTime(0);
					}
					break;
				case youtube_player.VIDEO_ENDED:
					if ((_currentState == youtube_player.VIDEO_PLAYING) || (_currentState == youtube_player.VIDEO_PAUSED)) {
						removeEventListener(Event.ENTER_FRAME, _checkVideoPlayStatus, false);
						_controls.stop();
						
						_controls.disable(video_controls.PLAY_BUTTON);
						_controls.disable(video_controls.STOP_BUTTON);
						_controls.disable(video_controls.SEEK_BAR);
					}
					break;
				case youtube_player.VIDEO_PLAYING:
					if (_currentState != youtube_player.VIDEO_PLAYING) {
						addEventListener(Event.ENTER_FRAME, _checkVideoPlayStatus, false, 0, true);
						_controls.play();
						
						_controls.disable(video_controls.PLAY_BUTTON);
						_controls.enable(video_controls.PAUSE_BUTTON);
						_controls.enable(video_controls.STOP_BUTTON);
						_controls.enable(video_controls.SEEK_BAR);
						_controls.enable(video_controls.TIME_BLOCK);
					}
					break;
				case youtube_player.VIDEO_PAUSED:
					if (_currentState == youtube_player.VIDEO_PLAYING) {
						removeEventListener(Event.ENTER_FRAME, _checkVideoPlayStatus, false);
						_controls.pause();
						
						_controls.enable(video_controls.PLAY_BUTTON);
						_controls.disable(video_controls.PAUSE_BUTTON);
						_controls.enable(video_controls.SEEK_BAR);
					}
					break;
				case youtube_player.VIDEO_BUFFERING:
					addEventListener(Event.ENTER_FRAME, _checkVideoBufferStatus, false, 0, true);
					break;
				case youtube_player.VIDEO_CUED:
					if (_player.getDuration() == 0) {
						_controls.disable(video_controls.TIME_BLOCK);
					}
					break;
			}
			_currentState = e.params.state;
			dispatchEvent(e);
		}
		
		/**
		 * handles the playlist-ready event by setting up the controls and redispatching the event
		 */
		private function _playlistReady(e:custom_event):void {
			trace("[youtube_wrapper] The playlist is now ready.");
			// when the playlist is first ready, it "selects" the first option in the list... we need to set a flag so it doesn't "play" the first thing
			_playlistJustLoaded = true;
			
			if (_controls != null) {
				var nextDisable:Boolean = true;
				var prevDisable:Boolean = true;
				if (_playlist != null) {
					if (_playlist.hasNext()) nextDisable = false;
					if (_playlist.hasPrevious()) prevDisable = false;
				}
				if (prevDisable) _controls.disable(video_controls.NEXT_BUTTON);
				if (nextDisable) _controls.disable(video_controls.PREVIOUS_BUTTON);
				
				_controls.disable(video_controls.PLAY_BUTTON);
				_controls.disable(video_controls.PAUSE_BUTTON);
				_controls.disable(video_controls.STOP_BUTTON);
				_controls.disable(video_controls.TIME_BLOCK);
			}
			
			dispatchEvent(new custom_event(PLAYLIST_READY));
		}
		
		/**
		 * processes the selection that was just made from the playlist
		 */
		private function _playlistSelect(e:custom_event):void {
			trace("[youtube_wrapper] A video was selected from the playlist:");
				trace("\tID:\t\t" + e.params.id);
				trace("\tType:\t" + e.params.type);
				trace("\tURL:\t" + e.params.url);
				// e.params.container -- a "container" that matches the playlist format, but isn't clickable - a "selected" version ;)
			
			if (_playlistJustLoaded && ((e.params.type == youtube_playlist.TYPE_PLAYLISTS) || !_settings.autoStartVideos)) {
				// the playlist just loaded, but we don't want anything selected so de-select the first one
				_playlist.deselectAll();
			} else {
				switch (e.params.type) {
					case youtube_playlist.TYPE_PLAYLISTS:
						// we have a list of playlists
						// url: playlist URL
						
						if (_playlistJustLoaded == false) {
							// load the selected playlist
							loadPlaylist(e.params.url);
						}
						break;
					case youtube_playlist.TYPE_PLAYLIST:
						// we have a playlist of videos
						// url: video URL
					case youtube_playlist.TYPE_VIDEO:
						// we have a single video
						// url: video URL
						
						if (_controls != null) {
							_controls.enable(video_controls.PLAY_BUTTON);
							_controls.disable(video_controls.STOP_BUTTON);
							_controls.disable(video_controls.PAUSE_BUTTON);
							_controls.setCurrentTime(0);
							_controls.setDuration(_player.getDuration());
						}
						
						if (!_playlistJustLoaded || _settings.autoStartVideos) {
							// re-dispatch the event so the outter movie can maybe set the "selected" video
							dispatchEvent(e);
							// "play" the video
							play(e.params.url, false, _settings.autoStartVideos);
						}
						break;
				}
			}
			
			_playlistJustLoaded = false;
			dispatchEvent(e);
		}
		
		/**
		 * process all of the passed settings and set any required default values
		 */
		private function _processSettings(settings:Object):void {
			if (settings == null) settings = new Object();
			_settings = new Object();
			
			_settings.autoStartVideos = ((settings.autoStartVideos != null) && (settings.autoStartVideos == true)) ? true : false;
			
			if (settings.playlist != null) {
				_settings.playlist = new Object();
				_settings.playlist.displayDescription				= (settings.playlist.displayDescription != null) ? settings.playlist.displayDescription : null;
				_settings.playlist.displayPlaylistNumberOfVideos	= (settings.playlist.displayPlaylistNumberOfVideos != null) ? settings.playlist.displayPlaylistNumberOfVideos : null;
				_settings.playlist.numberOfItems					= (settings.playlist.numberOfItems != null) ? settings.playlist.numberOfItems : null;
				_settings.playlist.itemAlpha						= (settings.playlist.itemAlpha != null) ? settings.playlist.itemAlpha : null;
				_settings.playlist.itemAlphaHover					= (settings.playlist.itemAlphaHover != null) ? settings.playlist.itemAlphaHover : null;
				_settings.playlist.itemAlphaSelected				= (settings.playlist.itemAlphaSelected != null) ? settings.playlist.itemAlphaSelected : null;
				_settings.playlist.itemBorderWidth					= (settings.playlist.itemBorderWidth != null) ? settings.playlist.itemBorderWidth : null;
				_settings.playlist.itemBorderWidthHover				= (settings.playlist.itemBorderWidthHover != null) ? settings.playlist.itemBorderWidthHover : null;
				_settings.playlist.itemBorderWidthSelected			= (settings.playlist.itemBorderWidthSelected != null) ? settings.playlist.itemBorderWidthSelected : null;
				_settings.playlist.itemBorderColor					= (settings.playlist.itemBorderColor != null) ? settings.playlist.itemBorderColor : null;
				_settings.playlist.itemBorderColorHover				= (settings.playlist.itemBorderColorHover != null) ? settings.playlist.itemBorderColorHover : null;
				_settings.playlist.itemBorderColorSelected			= (settings.playlist.itemBorderColorSelected != null) ? settings.playlist.itemBorderColorSelected : null;
				_settings.playlist.itemBackgroundColor				= (settings.playlist.itemBackgroundColor != null) ? settings.playlist.itemBackgroundColor : null;
				_settings.playlist.itemBackgroundColorHover			= (settings.playlist.itemBackgroundColorHover != null) ? settings.playlist.itemBackgroundColorHover : null;
				_settings.playlist.itemBackgroundColorSelected		= (settings.playlist.itemBackgroundColorSelected != null) ? settings.playlist.itemBackgroundColorSelected : null;
				_settings.playlist.itemBackgroundAlpha				= (settings.playlist.itemBackgroundAlpha != null) ? settings.playlist.itemBackgroundAlpha : null;
				_settings.playlist.itemBackgroundAlphaHover			= (settings.playlist.itemBackgroundAlphaHover != null) ? settings.playlist.itemBackgroundAlphaHover : null;
				_settings.playlist.itemBackgroundAlphaSelected		= (settings.playlist.itemBackgroundAlphaSelected != null) ? settings.playlist.itemBackgroundAlphaSelected : null;
				_settings.playlist.itemContentMargin				= (settings.playlist.itemContentMargin != null) ? settings.playlist.itemContentMargin : null;
				_settings.playlist.itemMargin						= (settings.playlist.itemMargin != null) ? settings.playlist.itemMargin : null;
				_settings.playlist.itemPadding						= (settings.playlist.itemPadding != null) ? settings.playlist.itemPadding : null;
				_settings.playlist.itemWidth						= (settings.playlist.itemWidth != null) ? settings.playlist.itemWidth : null;
				_settings.playlist.displayContentBackground			= (settings.playlist.displayContentBackground != null) ? settings.playlist.displayContentBackground : null;
				_settings.playlist.contentBackgroundBorderWidth		= (settings.playlist.contentBackgroundBorderWidth != null) ? settings.playlist.contentBackgroundBorderWidth : null;
				_settings.playlist.contentBackgroundBorderColor		= (settings.playlist.contentBackgroundBorderColor != null) ? settings.playlist.contentBackgroundBorderColor : null;
				_settings.playlist.contentBackgroundColor			= (settings.playlist.contentBackgroundColor != null) ? settings.playlist.contentBackgroundColor : null;
				_settings.playlist.contentPadding					= (settings.playlist.contentPadding != null) ? settings.playlist.contentPadding : null;
				_settings.playlist.itemTitleFontSize				= (settings.playlist.itemTitleFontSize != null) ? settings.playlist.itemTitleFontSize : null;
				_settings.playlist.itemTitleColor					= (settings.playlist.itemTitleColor != null) ? settings.playlist.itemTitleColor : null;
				_settings.playlist.itemTitleBold					= (settings.playlist.itemTitleBold != null) ? settings.playlist.itemTitleBold : null;
				_settings.playlist.itemTitleWordWrap				= (settings.playlist.itemTitleWordWrap != null) ? settings.playlist.itemTitleWordWrap : null;
				_settings.playlist.itemFontSize						= (settings.playlist.itemFontSize != null) ? settings.playlist.itemFontSize : null;
				_settings.playlist.itemColor						= (settings.playlist.itemColor != null) ? settings.playlist.itemColor : null;
				_settings.playlist.displayThumbnail					= (settings.playlist.displayThumbnail != null) ? settings.playlist.displayThumbnail : null;
				_settings.playlist.thumbnailWidth					= (settings.playlist.thumbnailWidth != null) ? settings.playlist.thumbnailWidth : null;
				_settings.playlist.thumbnailHeight					= (settings.playlist.thumbnailHeight != null) ? settings.playlist.thumbnailHeight : null;
				_settings.playlist.displayThumbnailBackground		= (settings.playlist.displayThumbnailBackground != null) ? settings.playlist.displayThumbnailBackground : null;
				_settings.playlist.thumbnailBackgroundBorderWidth	= (settings.playlist.thumbnailBackgroundBorderWidth != null) ? settings.playlist.thumbnailBackgroundBorderWidth : null;
				_settings.playlist.thumbnailBackgroundBorderColor	= (settings.playlist.thumbnailBackgroundBorderColor != null) ? settings.playlist.thumbnailBackgroundBorderColor : null;
				_settings.playlist.thumbnailBackgroundColor			= (settings.playlist.thumbnailBackgroundColor != null) ? settings.playlist.thumbnailBackgroundColor : null;
				_settings.playlist.thumbnailPadding					= (settings.playlist.thumbnailPadding != null) ? settings.playlist.thumbnailPadding : null;
			}
			
			if (settings.controls != null) {
				_settings.controls = new Object();
				_settings.controls.controlsHeight			= (settings.controls.controlsHeight != null) ? settings.controls.controlsHeight : null;
				_settings.controls.playButtonUp				= (settings.controls.playButtonUp != null) ? settings.controls.playButtonUp : null;
				_settings.controls.playButtonOver			= (settings.controls.playButtonOver != null) ? settings.controls.playButtonOver : null;
				_settings.controls.playButtonDown			= (settings.controls.playButtonDown != null) ? settings.controls.playButtonDown : null;
				_settings.controls.playButtonX				= (settings.controls.playButtonX != null) ? settings.controls.playButtonX : null;
				_settings.controls.playButtonY				= (settings.controls.playButtonY != null) ? settings.controls.playButtonY : null;
				_settings.controls.displayPlayButton		= (settings.controls.displayPlayButton != null) ? settings.controls.displayPlayButton : null;
				_settings.controls.pauseButtonUp			= (settings.controls.pauseButtonUp != null) ? settings.controls.pauseButtonUp : null;
				_settings.controls.pauseButtonOver			= (settings.controls.pauseButtonOver != null) ? settings.controls.pauseButtonOver : null;
				_settings.controls.pauseButtonDown			= (settings.controls.pauseButtonDown != null) ? settings.controls.pauseButtonDown : null;
				_settings.controls.displayPauseButton		= (settings.controls.displayPauseButton != null) ? settings.controls.displayPauseButton : null;
				_settings.controls.stopButtonUp				= (settings.controls.stopButtonUp != null) ? settings.controls.stopButtonUp : null;
				_settings.controls.stopButtonOver			= (settings.controls.stopButtonOver != null) ? settings.controls.stopButtonOver : null;
				_settings.controls.stopButtonDown			= (settings.controls.stopButtonDown != null) ? settings.controls.stopButtonDown : null;
				_settings.controls.stopButtonX				= (settings.controls.stopButtonX != null) ? settings.controls.stopButtonX : null;
				_settings.controls.stopButtonY				= (settings.controls.stopButtonY != null) ? settings.controls.stopButtonY : null;
				_settings.controls.displayStopButton		= (settings.controls.displayStopButton != null) ? settings.controls.displayStopButton : null;
				_settings.controls.nextButtonUp				= (settings.controls.nextButtonUp != null) ? settings.controls.nextButtonUp : null;
				_settings.controls.nextButtonOver			= (settings.controls.nextButtonOver != null) ? settings.controls.nextButtonOver : null;
				_settings.controls.nextButtonDown			= (settings.controls.nextButtonDown != null) ? settings.controls.nextButtonDown : null;
				_settings.controls.nextButtonX				= (settings.controls.nextButtonX != null) ? settings.controls.nextButtonX : null;
				_settings.controls.nextButtonY				= (settings.controls.nextButtonY != null) ? settings.controls.nextButtonY : null;
				_settings.controls.displayNextButton		= (settings.controls.displayNextButton != null) ? settings.controls.displayNextButton : null;
				_settings.controls.previousButtonUp			= (settings.controls.previousButtonUp != null) ? settings.controls.previousButtonUp : null;
				_settings.controls.previousButtonOver		= (settings.controls.previousButtonOver != null) ? settings.controls.previousButtonOver : null;
				_settings.controls.previousButtonDown		= (settings.controls.previousButtonDown != null) ? settings.controls.previousButtonDown : null;
				_settings.controls.previousButtonX			= (settings.controls.previousButtonX != null) ? settings.controls.previousButtonX : null;
				_settings.controls.previousButtonY			= (settings.controls.previousButtonY != null) ? settings.controls.previousButtonY : null;
				_settings.controls.displayPreviousButton	= (settings.controls.displayPreviousButton != null) ? settings.controls.displayPreviousButton : null;
				_settings.controls.volumeButtonUp			= (settings.controls.volumeButtonUp != null) ? settings.controls.volumeButtonUp : null;
				_settings.controls.volumeButtonOver			= (settings.controls.volumeButtonOver != null) ? settings.controls.volumeButtonOver : null;
				_settings.controls.volumeButtonDown			= (settings.controls.volumeButtonDown != null) ? settings.controls.volumeButtonDown : null;
				_settings.controls.volumeButtonX			= (settings.controls.volumeButtonX != null) ? settings.controls.volumeButtonX : null;
				_settings.controls.volumeButtonY			= (settings.controls.volumeButtonY != null) ? settings.controls.volumeButtonY : null;
				_settings.controls.displayVolumeButton		= (settings.controls.displayVolumeButton != null) ? settings.controls.displayVolumeButton : null;
				_settings.controls.fullscreenButtonUp		= (settings.controls.fullscreenButtonUp != null) ? settings.controls.fullscreenButtonUp : null;
				_settings.controls.fullscreenButtonOver		= (settings.controls.fullscreenButtonOver != null) ? settings.controls.fullscreenButtonOver : null;
				_settings.controls.fullscreenButtonDown		= (settings.controls.fullscreenButtonDown != null) ? settings.controls.fullscreenButtonDown : null;
				_settings.controls.fullscreenButtonX		= (settings.controls.fullscreenButtonX != null) ? settings.controls.fullscreenButtonX : null;
				_settings.controls.fullscreenButtonY		= (settings.controls.fullscreenButtonY != null) ? settings.controls.fullscreenButtonY : null;
				_settings.controls.displayFullscreenButton	= (settings.controls.displayFullscreenButton != null) ? settings.controls.displayFullscreenButton : null;
				_settings.controls.displaySeekBar			= (settings.controls.displaySeekBar != null) ? settings.controls.displaySeekBar : null;
				_settings.controls.displaySeekBarBuffer		= (settings.controls.displaySeekBarBuffer != null) ? settings.controls.displaySeekBarBuffer : null;
				_settings.controls.seekBarBackground		= (settings.controls.seekBarBackground != null) ? settings.controls.seekBarBackground : null;
				_settings.controls.seekBarBuffer			= (settings.controls.seekBarBuffer != null) ? settings.controls.seekBarBuffer : null;
				_settings.controls.seekBarPlayed			= (settings.controls.seekBarPlayed != null) ? settings.controls.seekBarPlayed : null;
				_settings.controls.seekBarScrubber			= (settings.controls.seekBarScrubber != null) ? settings.controls.seekBarScrubber : null;
				_settings.controls.seekBarX					= (settings.controls.seekBarX != null) ? settings.controls.seekBarX : null;
				_settings.controls.seekBarY					= (settings.controls.seekBarY != null) ? settings.controls.seekBarY : null;
				_settings.controls.displayTimeBlock			= (settings.controls.displayTimeBlock != null) ? settings.controls.displayTimeBlock : null;
				_settings.controls.timeBlockX				= (settings.controls.timeBlockX != null) ? settings.controls.timeBlockX : null;
				_settings.controls.timeBlockY				= (settings.controls.timeBlockY != null) ? settings.controls.timeBlockY : null;
				_settings.controls.timeBlockColor			= (settings.controls.timeBlockColor != null) ? settings.controls.timeBlockColor : null;
				_settings.controls.timeBlockBold			= (settings.controls.timeBlockBold != null) ? settings.controls.timeBlockBold : null;
			}
		}

		/**
		 * processes the current setup level
		 */
		private function _setup():void {
			if ((_setupLevel <= 0) && (_settings.controls != null)) {
				// we have settings for the controls, let's set them up
				_createVideoControls();
			} else if ((_setupLevel <= 1) && (_settings.playlist != null) && (_playlist == null)) {
				// we have settings for the playlist, let's set it up
				_createVideoPlaylist();
			} else if ((_setupLevel <= 2) && (_player == null)) {
				// we can setup the player now =]
				_createVideoPlayer();
			} else {
				// either we have loaded everything we need, or we don't have anything!
				trace("[youtube_wrapper] Setup is complete.");
				_isReady = true;
				dispatchEvent(new custom_event(YOUTUBE_READY, {controls: _controls, playlist: _playlist, player: _player}));
			}
		}
	}
}