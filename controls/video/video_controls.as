/**
 * Creates a generic set of video controls that can be dropped in and interfaced with any type of video player.
 *
 * Usage: {{{
 *    var controls:video_controls = new video_controls(settings); // 'settings' is an object with all required settings specified
 *    controls.addEventListener(video_controls.CONTROLS_READY, _controlsReady, false, 0, true);
 *    private function _controlsReady(e:custom_event):void {
 *    	controls.removeEventListener(video_controls.CONTROLS_READY, _controlsReady, 		false);
 *    	controls.addEventListener(video_controls.VIDEO_NEXT,		_controlsNext,			false, 0, true);
 *    	controls.addEventListener(video_controls.VIDEO_PAUSE,		_controlsPause,			false, 0, true);
 *    	controls.addEventListener(video_controls.VIDEO_PLAY,		_controlsPlay,			false, 0, true);
 *    	controls.addEventListener(video_controls.VIDEO_PREVIOUS,	_controlsPrevious,		false, 0, true);
 *    	controls.addEventListener(video_controls.VIDEO_SEEK,		_controlsSeek,			false, 0, true);
 *    	controls.addEventListener(video_controls.VIDEO_STOP,		_controlsStop,			false, 0, true);
 *    }
 * }}}
 */

package classes.controls.video {
	import classes.controls.button;
	import classes.controls.slider;
	import classes.controls.video.video_buffer_slider;
	import classes.events.custom_event;
	import classes.file.image_loader;
	import classes.geom.simple_rectangle;
	import classes.text.text;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class video_controls extends MovieClip {
		// Global vars
		public static var CONTROLS_READY:String		= new String("controlsReady");
		public static var NEXT_BUTTON:String		= new String("nextButton");
		public static var PAUSE_BUTTON:String		= new String("pauseButton");
		public static var PLAY_BUTTON:String		= new String("playButton");
		public static var PREVIOUS_BUTTON:String	= new String("previousButton");
		public static var SEEK_BAR:String			= new String("seekBar");
		public static var STOP_BUTTON:String		= new String("stopButton");
		public static var TIME_BLOCK:String			= new String("timeBlock");
		public static var VIDEO_FULLSCREEN:String	= new String("videoFullscreen");
		public static var VIDEO_NEXT:String			= new String("videoNext");
		public static var VIDEO_PAUSE:String		= new String("videoPause");
		public static var VIDEO_PLAY:String			= new String("videoPlay");
		public static var VIDEO_PREVIOUS:String		= new String("videoPrevious");
		public static var VIDEO_SEEK:String			= new String("videoSeek");
		public static var VIDEO_STOP:String			= new String("videoStop");
		public static var VOLUME_BUTTON:String		= new String("volumeButton");
		public static var VOLUME_CHANGE:String		= new String("volumeChange");
		private var _controls:Array					= null;		// holds each individual control and their properties
		private var _duration:Number				= 0;		// current video duration used in the time block
		private var _imgLoader:image_loader			= null;		// global image_loader object
		private var _isReady:Boolean				= false;	// flag to indicate if the video_controls object is ready
		private var _settings:Object				= null;		// holds all of the current settings
		private var _waitForSeekBar:Boolean			= true;		// flag to indicate if we need to wait for the seek bar
		
		/**
		 * Constructor: sets up the video_controls.
		 *
		 * @param Object settings.
		 */
		public function video_controls(settings:Object):void {
			_setupImageLoader();
			_processSettings(settings);
			_createUI();
		}
		
		/**
		 * Disables the specified video control.
		 *
		 * @param String name Name of the control to disable.
		 */
		public function disable(name:String):void {
			switch (name) {
				case PLAY_BUTTON:
					if (_controls["play_button"] != null) {
						_disableButton(_controls["play_button"].button);
					}
					break;
				case PAUSE_BUTTON:
					if (_controls["pause_button"] != null) {
						_disableButton(_controls["pause_button"].button);
					}
					break;
				case STOP_BUTTON:
					if (_controls["stop_button"] != null) {
						_disableButton(_controls["stop_button"].button);
					}
					break;
				case NEXT_BUTTON:
					if (_controls["next_button"] != null) {
						_disableButton(_controls["next_button"].button);
					}
					break;
				case PREVIOUS_BUTTON:
					if (_controls["previous_button"] != null) {
						_disableButton(_controls["previous_button"].button);
					}
					break;
				case SEEK_BAR:
					if (_controls["seek_bar"] != null) {
						_controls["seek_bar"].disable();
					}
					break;
				case TIME_BLOCK:
					if (_controls["time_block"] != null) {
						_controls["time_block"]["clip"].alpha = 0;
						_controls["time_block"]["clip"].visible = false;
					}
					break;
				case VOLUME_BUTTON:
					if (_controls["volume_button"] != null) {
						_disableButton(_controls["volume_button"].button);
					}
					break;
			}
		}
		
		/**
		 * Enables the specified video control.
		 *
		 * @param String name name of the control to enable.
		 */
		public function enable(name:String):void {
			switch (name) {
				case PLAY_BUTTON:
					if (_controls["play_button"] != null) {
						_enableButton(_controls["play_button"].button);
					}
					break;
				case PAUSE_BUTTON:
					if (_controls["pause_button"] != null) {
						_enableButton(_controls["pause_button"].button);
					}
					break;
				case STOP_BUTTON:
					if (_controls["stop_button"] != null) {
						_enableButton(_controls["stop_button"].button);
					}
					break;
				case NEXT_BUTTON:
					if (_controls["next_button"] != null) {
						_enableButton(_controls["next_button"].button);
					}
					break;
				case PREVIOUS_BUTTON:
					if (_controls["previous_button"] != null) {
						_enableButton(_controls["previous_button"].button);
					}
					break;
				case SEEK_BAR:
					if (_controls["seek_bar"] != null) {
						_controls["seek_bar"].enable();
					}
					break;
				case TIME_BLOCK:
					if (_controls["time_block"] != null) {
						_controls["time_block"]["clip"].alpha = 1;
						_controls["time_block"]["clip"].visible = true;
					}
					break;
				case VOLUME_BUTTON:
					if (_controls["volume_button"] != null) {
						_enableButton(_controls["volume_button"].button);
					}
					break;
			}
		}
		
		/**
		 * Dispatches a pause-button click event.
		 */
		public function pause():void {
			_pauseButtonClick(new custom_event(button.CLICK));
		}
		
		/**
		 * Dispatches a play-button click event.
		 */
		public override function play():void {
			_playButtonClick(new custom_event(button.CLICK));
		}
		
		/**
		 * Seeks the video to the specified location.
		 *
		 * @param Number value Time to seek the video to.
		 */
		public function seekTo(value:Number):void {
			if ((_controls["seek_bar"] == null) || _controls["seek_bar"].isLocked()) return;
			_controls["seek_bar"].update(value);
		}
		
		/**
		 * Update's the time block with the current time from the video.
		 *
		 * @param Number value Value to set the current time-text to.
		 */
		public function setCurrentTime(value:Number):void {
			if (!_settings.displayTimeBlock) return;
			var w:Number = _controls["time_block"]["current_time"].width;
			_controls["time_block"]["current_time"].getChildAt(0).value = _formatTime(value, (_duration >= 3600));
			
			if (_controls["time_block"]["current_time"].width != w) {
				_controls["time_block"]["clip"].getChildAt(1).x = _controls["time_block"]["current_time"].width;
				_controls["time_block"]["clip"].getChildAt(2).x = _controls["time_block"]["clip"].getChildAt(1).x + _controls["time_block"]["clip"].getChildAt(1).width + 10;
			}
		}
		
		/**
		 * Updates the time block with the new video's duration.
		 *
		 * @param Number value Value to set the current duration-text to.
		 */
		public function setDuration(value:Number):void {
			if (!_settings.displayTimeBlock) return;
			_controls["time_block"]["total_time"].getChildAt(0).value = _formatTime(value);
			_duration = value;
		}
		
		/**
		 * Dispatches a stop-button click event.
		 */
		public override function stop():void {
			_stopButtonClick(new custom_event(button.CLICK));
		}
		
		/**
		 * Updates the seek bar's buffer.
		 *
		 * @param Number value Value to update the buffer by.
		 */
		public function updateBuffer(value:Number):void {
			if (_controls["seek_bar"] == null) return;
			_controls["seek_bar"].updateBuffer(value);
		}
		
		/**
		 * Using the passed items it creates a button for the video controls.
		 *
		 * @param String control		Name of the control.
		 * @param String upStateUrl		URL to the "up" image.
		 * @param String overStateUrl	URL to the "over" image.
		 * @param String downStateUrl	URL to the "down" image.
		 * @return MovieClip			The created button.
		 */
		private function _createButton(control:String, upStateUrl:String, overStateUrl:String, downStateUrl:String):MovieClip {
			if (upStateUrl == "") return null;
			
			var up:MovieClip = new MovieClip();
			_imgLoader.load(upStateUrl, up, "video_controls_up_" + control);
			
			var over:MovieClip = new MovieClip();
			_imgLoader.load(overStateUrl, over, "video_controls_over_" + control);
			
			var down:MovieClip = new MovieClip();
			_imgLoader.load(downStateUrl, down, "video_controls_down_" + control);
			
			var btn:button = new button(up, over, down);
			return btn;
		}
		
		/**
		 * Checks if all of the buttons and seek bar have been setup.
		 */
		private function _checkReady():void {
			if ((_controls["play_button"] != null) && (_controls["play_button"].count < 3)) return;
			if ((_controls["pause_button"] != null) && (_controls["pause_button"].count < 3)) return;
			if ((_controls["stop_button"] != null) && (_controls["stop_button"].count < 3)) return;
			if ((_controls["next_button"] != null) && (_controls["next_button"].count < 3)) return;
			if ((_controls["previous_button"] != null) && (_controls["previous_button"].count < 3)) return;
			if ((_controls["volume_button"] != null) && (_controls["volume_button"].count < 3)) return;
			if ((_controls["fullscreen_button"] != null) && (_controls["fullscreen_button"].count < 3)) return;
			if (_waitForSeekBar) return;
			
			// if we got this far, it means we're ready!
			dispatchEvent(new custom_event(CONTROLS_READY));
		}
		
		/**
		 * Creates the video_buffer_slider object as a seek bar.
		 */
		private function _createSeekBar():void {
			if (_settings.displaySeekBar) {
				var sliderSett:Object = new Object();
				sliderSett.direction	= slider.HORIZONTAL;
				sliderSett.minValue		= 0;
				sliderSett.maxValue		= 100;
				sliderSett.value		= 0;
				sliderSett.liveUpdate	= false;
				
				sliderSett.length				= _settings.seekBarWidth;
				sliderSett.scrubberImage		= _settings.seekBarScrubber;
				sliderSett.barBackgroundImage	= _settings.seekBarBackground;
				sliderSett.barBufferImage		= (_settings.displaySeekBarBuffer) ? _settings.seekBarBuffer : null;
				sliderSett.barPlayedImage		= _settings.seekBarPlayed;
				
				var seekBar:video_buffer_slider = new video_buffer_slider(sliderSett);
				
				_controls["seek_bar"] = new Object();
				_controls["seek_bar"] = seekBar;
				seekBar.x = _settings.seekBarX;
				seekBar.y = _settings.seekBarY;//(_settings.controlsHeight - seekBar.height) / 2;
				addChild(_controls["seek_bar"]);
				seekBar.addEventListener(video_buffer_slider.SLIDER_READY, _seekBarReady, false, 0, true);
				seekBar.addEventListener(slider.CHANGE, _seekChanged, false, 0, true);
			} else {
				_waitForSeekBar = false;
				_checkReady();
			}
		}
		
		/**
		 * Creates the textual current/total time display block.
		 */
		private function _createTimeBlock():void {
			if (!_settings.displayTimeBlock) return;
			
			_controls["time_block"] = new Array();
			_controls["time_block"]["current_time"] = new MovieClip();
			var curr_text:text = new text(_formatTime(0), _controls["time_block"]["current_time"]);
			curr_text.color = _settings.timeBlockColor;
			curr_text.bold = _settings.timeBlockBold;
			
			_controls["time_block"]["total_time"] = new MovieClip();
			var total_text:text = new text(_formatTime(0), _controls["time_block"]["total_time"]);
			total_text.color = _settings.timeBlockColor;
			total_text.bold = _settings.timeBlockBold;
			
			var div:MovieClip = new MovieClip();
			var div_text:text = new text("/", div);
			div.color = _settings.timeBlockColor;
			div.bold = _settings.timeBlockBold;
			
			_controls["time_block"]["clip"] = new MovieClip();
			_controls["time_block"]["clip"].addChild(_controls["time_block"]["current_time"]);
			_controls["time_block"]["clip"].addChild(div);
			div.x = _controls["time_block"]["current_time"].width;
			_controls["time_block"]["clip"].addChild(_controls["time_block"]["total_time"]);
			_controls["time_block"]["total_time"].x = div.x + div.width + 10;
			
			_controls["time_block"]["clip"].x = _settings.timeBlockX;
			_controls["time_block"]["clip"].y = _settings.timeBlockY;
			addChild(_controls["time_block"]["clip"]);
		}
		
		/**
		 * Creates the UI and sets up all of the buttons.
		 */
		private function _createUI():void {
			if (_settings.displayPlayButton) {
				_controls["play_button"] = new Object();
				_controls["play_button"].count = 0;
				_controls["play_button"].button = _createButton("play_button", _settings.playButtonUp, _settings.playButtonOver, _settings.playButtonDown);
				if (_controls["play_button"].button != null) {
					_controls["play_button"].button.x = _settings.playButtonX;
					_controls["play_button"].button.y = _settings.playButtonY;
					_controls["play_button"].button.addEventListener(button.CLICK, _playButtonClick, false, 0, true);
				} else {
					_controls["play_button"] = null;
				}
			}
			
			if (_settings.displayPauseButton) {
				_controls["pause_button"] = new Object();
				_controls["pause_button"].count = 0;
				_controls["pause_button"].button = _createButton("pause_button", _settings.pauseButtonUp, _settings.pauseButtonOver, _settings.pauseButtonDown);
				if (_controls["pause_button"].button != null) {
					_controls["pause_button"].button.x = _settings.pauseButtonX;
					_controls["pause_button"].button.y = _settings.pauseButtonY;
					_controls["pause_button"].button.addEventListener(button.CLICK, _pauseButtonClick, false, 0, true);
				} else {
					_controls["pause_button"] = null;
				}
			}
			
			if (_settings.displayStopButton) {
				_controls["stop_button"] = new Object();
				_controls["stop_button"].count = 0;
				_controls["stop_button"].button = _createButton("stop_button", _settings.stopButtonUp, _settings.stopButtonOver, _settings.stopButtonDown);
				if (_controls["stop_button"].button != null) {
					_controls["stop_button"].button.x = _settings.stopButtonX;
					_controls["stop_button"].button.y = _settings.stopButtonY;
					_controls["stop_button"].button.addEventListener(button.CLICK, _stopButtonClick, false, 0, true);
				} else {
					_controls["stop_button"] = null;
				}
			}
			
			if (_settings.displayNextButton) {
				_controls["next_button"] = new Object();
				_controls["next_button"].count = 0;
				_controls["next_button"].button = _createButton("next_button", _settings.nextButtonUp, _settings.nextButtonOver, _settings.nextButtonDown);
				if (_controls["next_button"].button != null) {
					_controls["next_button"].button.x = _settings.nextButtonX;
					_controls["next_button"].button.y = _settings.nextButtonY;
					_controls["next_button"].button.addEventListener(button.CLICK, _nextButtonClick, false, 0, true);
				} else {
					_controls["next_button"] = null;
				}
			}
			
			if (_settings.displayPreviousButton) {
				_controls["previous_button"] = new Object();
				_controls["previous_button"].count = 0;
				_controls["previous_button"].button = _createButton("previous_button", _settings.previousButtonUp, _settings.previousButtonOver, _settings.previousButtonDown);
				if (_controls["previous_button"].button != null) {
					_controls["previous_button"].button.x = _settings.previousButtonX;
					_controls["previous_button"].button.y = _settings.previousButtonY;
					_controls["previous_button"].button.addEventListener(button.CLICK, _previousButtonClick, false, 0, true);
				} else {
					_controls["previous_button"] = null;
				}
			}
			
			if (_settings.displayVolumeButton) {
				_controls["volume_button"] = new Object();
				_controls["volume_button"].count = 0;
				_controls["volume_button"].button = _createButton("volume_button", _settings.volumeButtonUp, _settings.volumeButtonOver, _settings.volumeButtonDown);
				if (_controls["volume_button"].button != null) {
					_controls["volume_button"].button.x = _settings.volumeButtonX;
					_controls["volume_button"].button.y = _settings.volumeButtonY;
					_controls["volume_button"].button.addEventListener(button.CLICK, _volumeButtonClick, false, 0, true);
				} else {
					_controls["volume_button"] = null;
				}
			}
			
			if (_settings.displayFullscreenButton) {
				_controls["fullscreen_button"] = new Object();
				_controls["fullscreen_button"].count = 0;
				_controls["fullscreen_button"].button = _createButton("fullscreen_button", _settings.fullscreenButtonUp, _settings.fullscreenButtonOver, _settings.fullscreenButtonDown);
				if (_controls["fullscreen_button"].button != null) {
					_controls["fullscreen_button"].button.x = _settings.fullscreenButtonX;
					_controls["fullscreen_button"].button.y = _settings.fullscreenButtonY;
					_controls["fullscreen_button"].button.addEventListener(button.CLICK, _fullscreenButtonClick, false, 0, true);
				} else {
					_controls["fullscreen_button"] = null;
				}
			}
			
			_createSeekBar();
			_createTimeBlock();
		}
		
		/**
		 * Creates the volume slider object.
		 */
		private function _createVolumeSlider():void {
			var volBg:simple_rectangle = new simple_rectangle((((_controls["volume_button"].button.width - 7) >= 20) ? (_controls["volume_button"].button.width - 7) : 20), 65, 0xdddddd, 2, 0xd4d4d4, 0);
			
			var sliderSett:Object = new Object();
			sliderSett.direction	= slider.VERTICAL_UP;
			sliderSett.length		= 60;
			sliderSett.minValue		= 0;
			sliderSett.maxValue		= 100;
			sliderSett.value		= 75;
			sliderSett.liveUpdate	= false;
			
			var volSlider:slider = new slider(sliderSett);
			_controls["volume_slider"] = new MovieClip();
			_controls["volume_slider"].addChild(volBg);
			_controls["volume_slider"].addChild(volSlider);
			volSlider.x = volBg.width / 2;
			volSlider.y = (volBg.height - volSlider.height) / 2;
			_controls["volume_slider"].visible = false;
			_controls["volume_slider"].enabled = false;
			addChild(_controls["volume_slider"]);
			_controls["volume_slider"].x = (_controls["volume_button"].button.x + ((_controls["volume_button"].button.width - _controls["volume_slider"].width) / 2));
			_controls["volume_slider"].y = (_controls["volume_button"].button.y - _controls["volume_slider"].height);
			volSlider.addEventListener(slider.CHANGE, _volumeChanged, false, 0, true);
		}
		
		/**
		 * Disables the specified button.
		 *
		 * @param MovieClip btn	The button to disable.
		 * @param Boolean hide	If true, the button will become invisible.
		 */
		private function _disableButton(btn:MovieClip, hide:Boolean = false):void {
			btn.disable();
			btn.enabled = false;
			btn.alpha = .8;
			if (hide) {
				btn.alpha = 0;
				btn.visible = false;
			}
		}
		
		/**
		 * Enables the specified button.
		 *
		 * @param MovieClip btn The button to enable.
		 */
		private function _enableButton(btn:MovieClip):void {
			btn.enable();
			btn.enabled = true;
			btn.alpha = 1;
			btn.visible = true;
		}
		
		/**
		 * Converts the given timestamp into a friendly time display.
		 *
		 * @param Number time
		 * @param Boolean force_hours
		 * @return String				The formatted time-string.
		 */
		private function _formatTime(time:Number, force_hours:Boolean = false):String {
			if (isNaN(time)) return "00:00"; // no time was passed, return 0!
			time				= int(time);
			var hours:Number	= int(time / 3600);
			var minutes:Number	= int(time / 60) % 60;
			var seconds:Number	= time % 60;
			return ((((hours > 0) || force_hours) ? (((hours < 10) ? ("0" + hours) : hours) + ":") : '') + (((minutes == 0) ? "00" : ((minutes < 10) ? ("0" + minutes) : minutes)) + ":" + ((seconds < 10) ? ("0" + seconds) : seconds)));
		}
		
		/**
		 * Listener for the fullscreen button's click event.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _fullscreenButtonClick(e:custom_event):void {
			dispatchEvent(new custom_event(VIDEO_FULLSCREEN));
		}
		
		/**
		 * Listener for an image_loaded event
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _imageLoaded(e:custom_event):void {
			var id:String = e.params.id;
			
			if (id.substr(0, 14) == "video_controls") {
				id = id.substr(15);
				var dir:String = id.substr(0, id.indexOf("_"));
				id = id.substr(dir.length + 1);
				
				_controls[id].count++;
				if (_controls[id].count == 3) {
					if (id == "pause_button") {
						_disableButton(_controls[id].button, ((_controls["play_button"] != null) ? true : false));
					} else if (id == "volume_button") {
						_createVolumeSlider();
					}
					addChild(_controls[id].button);
				}
				
				_checkReady();
			}
		}
		
		/**
		 * Listener for the next button's click event.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _nextButtonClick(e:custom_event):void {
			dispatchEvent(new custom_event(VIDEO_NEXT));
		}
		
		/**
		 * Listener for the pause button's click event.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _pauseButtonClick(e:custom_event):void {
			dispatchEvent(new custom_event(VIDEO_PAUSE));
			// check if the pause button exists; if so, hide it - but, if the play button doesn't exist, just "disable" it
			if (_controls["pause_button"] != null) _disableButton(_controls["pause_button"].button, ((_controls["play_button"] == null) ? false : true));
			
			// check if the play button exists, if so enable it
			if (_controls["play_button"] != null) _enableButton(_controls["play_button"].button);
		}
		
		/**
		 * Listener for the play button's click event.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _playButtonClick(e:custom_event):void {
			dispatchEvent(new custom_event(VIDEO_PLAY));
			// check if the play button exists; if so, hide it - but, if the pause button doesn't exist, just "disable" it
			if (_controls["play_button"] != null) _disableButton(_controls["play_button"].button, ((_controls["pause_button"] == null) ? false : true));
			
			// check if the pause button exists, if so enable it
			if (_controls["pause_button"] != null) _enableButton(_controls["pause_button"].button);
		}
		
		/**
		 * Listener for the previous button's click event.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _previousButtonClick(e:custom_event):void {
			dispatchEvent(new custom_event(VIDEO_PREVIOUS));
		}
		
		/**
		 * Processes all of the passed settings and sets and required default values.
		 *
		 * @param Object settings.
		 */
		private function _processSettings(settings:Object):void {
			_controls = new Array();
			_settings = new Object();
			
			// general settings
			_settings.controlsHeight			= ((settings.controlsHeight != null) && (Number(settings.controlsHeight) > 0)) ? Number(settings.controlsHeight) : 50;
			
			// play button
			_settings.playButtonUp				= ((settings.playButtonUp != null) && (settings.playButtonUp != "")) ? settings.playButtonUp : "";
			_settings.playButtonOver			= ((settings.playButtonOver != null) && (settings.playButtonOver != "")) ? settings.playButtonOver : _settings.playButtonUp;
			_settings.playButtonDown			= ((settings.playButtonDown != null) && (settings.playButtonDown != "")) ? settings.playButtonDown : _settings.playButtonOver;
			_settings.playButtonX				= ((settings.playButtonX != null) && (Number(settings.playButtonX) >= 0)) ? Number(settings.playButtonX) : 0;
			_settings.playButtonY				= ((settings.playButtonY != null) && (Number(settings.playButtonY) >= 0)) ? Number(settings.playButtonY) : 0;
			_settings.displayPlayButton			= ((settings.displayPlayButton != null) && ((settings.displayPlayButton == "false") || (_settings.playButtonUp == ""))) ? false : true;
			
			// pause button
			_settings.pauseButtonUp				= ((settings.pauseButtonUp != null) && (settings.pauseButtonUp != "")) ? settings.pauseButtonUp : "";
			_settings.pauseButtonOver			= ((settings.pauseButtonOver != null) && (settings.pauseButtonOver != "")) ? settings.pauseButtonOver : _settings.pauseButtonUp;
			_settings.pauseButtonDown			= ((settings.pauseButtonDown != null) && (settings.pauseButtonDown != "")) ? settings.pauseButtonDown : _settings.pauseButtonOver;
			_settings.pauseButtonX				= _settings.playButtonX;
			_settings.pauseButtonY				= _settings.playButtonY;
			_settings.displayPauseButton		= ((settings.displayPauseButton != null) && ((settings.displayPauseButton == "false") || (_settings.pauseButtonUp == ""))) ? false : true;
			
			// stop
			_settings.stopButtonUp				= ((settings.stopButtonUp != null) && (settings.stopButtonUp != "")) ? settings.stopButtonUp : "";
			_settings.stopButtonOver			= ((settings.stopButtonOver != null) && (settings.stopButtonOver != "")) ? settings.stopButtonOver : _settings.stopButtonUp;
			_settings.stopButtonDown			= ((settings.stopButtonDown != null) && (settings.stopButtonDown != "")) ? settings.stopButtonDown : _settings.stopButtonOver;
			_settings.stopButtonX				= ((settings.stopButtonX != null) && (Number(settings.stopButtonX) >= 0)) ? Number(settings.stopButtonX) : 0;
			_settings.stopButtonY				= ((settings.stopButtonY != null) && (Number(settings.stopButtonY) >= 0)) ? Number(settings.stopButtonY) : 0;
			_settings.displayStopButton			= ((settings.displayStopButton != null) && ((settings.displayStopButton == "false") || (_settings.stopButtonUp == ""))) ? false : true;
			
			// next button
			_settings.nextButtonUp				= ((settings.nextButtonUp != null) && (settings.nextButtonUp != "")) ? settings.nextButtonUp : "";
			_settings.nextButtonOver			= ((settings.nextButtonOver != null) && (settings.nextButtonOver != "")) ? settings.nextButtonOver : _settings.nextButtonUp;
			_settings.nextButtonDown			= ((settings.nextButtonDown != null) && (settings.nextButtonDown != "")) ? settings.nextButtonDown : _settings.nextButtonOver;
			_settings.nextButtonX				= ((settings.nextButtonX != null) && (Number(settings.nextButtonX) >= 0)) ? Number(settings.nextButtonX) : 0;
			_settings.nextButtonY				= ((settings.nextButtonY != null) && (Number(settings.nextButtonY) >= 0)) ? Number(settings.nextButtonY) : 0;
			_settings.displayNextButton			= ((settings.displayNextButton != null) && ((settings.displayNextButton == "false") || (_settings.nextButtonUp == ""))) ? false : true;
			
			// previous button
			_settings.previousButtonUp			= ((settings.previousButtonUp != null) && (settings.previousButtonUp != "")) ? settings.previousButtonUp : "";
			_settings.previousButtonOver		= ((settings.previousButtonOver != null) && (settings.previousButtonOver != "")) ? settings.previousButtonOver : _settings.previousButtonUp;
			_settings.previousButtonDown		= ((settings.previousButtonDown != null) && (settings.previousButtonDown != "")) ? settings.previousButtonDown : _settings.previousButtonOver;
			_settings.previousButtonX			= ((settings.previousButtonX != null) && (Number(settings.previousButtonX) >= 0)) ? Number(settings.previousButtonX) : 0;
			_settings.previousButtonY			= ((settings.previousButtonY != null) && (Number(settings.previousButtonY) >= 0)) ? Number(settings.previousButtonY) : 0;
			_settings.displayPreviousButton		= ((settings.displayPreviousButton != null) && ((settings.displayPreviousButton == "false") || (_settings.previousButtonUp == ""))) ? false : true;
			
			// volume button
			_settings.volumeButtonUp			= ((settings.volumeButtonUp != null) && (settings.volumeButtonUp != "")) ? settings.volumeButtonUp : "";
			_settings.volumeButtonOver			= ((settings.volumeButtonOver != null) && (settings.volumeButtonOver != "")) ? settings.volumeButtonOver : _settings.volumeButtonUp;
			_settings.volumeButtonDown			= ((settings.volumeButtonDown != null) && (settings.volumeButtonDown != "")) ? settings.volumeButtonDown : _settings.volumeButtonOver;
			_settings.volumeButtonX				= ((settings.volumeButtonX != null) && (Number(settings.volumeButtonX) >= 0)) ? Number(settings.volumeButtonX) : 0;
			_settings.volumeButtonY				= ((settings.volumeButtonY != null) && (Number(settings.volumeButtonY) >= 0)) ? Number(settings.volumeButtonY) : 0;
			_settings.displayVolumeButton		= ((settings.displayVolumeButton != null) && ((settings.displayVolumeButton == "false") || (_settings.volumeButtonUp == ""))) ? false : true;
			
			// fullscreen button
			_settings.fullscreenButtonUp		= ((settings.fullscreenButtonUp != null) && (settings.fullscreenButtonUp != "")) ? settings.fullscreenButtonUp : "";
			_settings.fullscreenButtonOver		= ((settings.fullscreenButtonOver != null) && (settings.fullscreenButtonOver != "")) ? settings.fullscreenButtonOver : _settings.fullscreenButtonUp;
			_settings.fullscreenButtonDown		= ((settings.fullscreenButtonDown != null) && (settings.fullscreenButtonDown != "")) ? settings.fullscreenButtonDown : _settings.fullscreenButtonOver;
			_settings.fullscreenButtonX			= ((settings.fullscreenButtonX != null) && (Number(settings.fullscreenButtonX) >= 0)) ? Number(settings.fullscreenButtonX) : 0;
			_settings.fullscreenButtonY			= ((settings.fullscreenButtonY != null) && (Number(settings.fullscreenButtonY) >= 0)) ? Number(settings.fullscreenButtonY) : 0;
			_settings.displayFullscreenButton	= ((settings.displayFullscreenButton != null) && ((settings.displayFullscreenButton == "false") || (_settings.fullscreenButtonUp == ""))) ? false : true;
			
			// seek bar
			_settings.displaySeekBar			= ((settings.displaySeekBar != null) && (settings.displaySeekBar == "false")) ? false : true;
			_settings.displaySeekBarBuffer		= ((settings.displaySeekBarBuffer != null) && ((settings.displaySeekBarBuffer == "false") || !_settings.displaySeekBar)) ? false : true;
			_settings.seekBarBackground			= ((settings.seekBarBackground != null) && (settings.seekBarBackground != "")) ? settings.seekBarBackground : "";
			_settings.seekBarBuffer				= ((settings.seekBarBuffer != null) && (settings.seekBarBuffer != "")) ? settings.seekBarBuffer : "";
			_settings.seekBarPlayed				= ((settings.seekBarPlayed != null) && (settings.seekBarPlayed != "")) ? settings.seekBarPlayed : "";
			_settings.seekBarScrubber			= ((settings.seekBarScrubber != null) && (settings.seekBarScrubber != "")) ? settings.seekBarScrubber : "";
			_settings.seekBarX					= ((settings.seekBarX != null) && (Number(settings.seekBarX) >= 0)) ? Number(settings.seekBarX) : 0;
			_settings.seekBarY					= ((settings.seekBarY != null) && (Number(settings.seekBarY) >= 0)) ? Number(settings.seekBarY) : 0;
			_settings.seekBarWidth				= ((settings.seekBarWidth != null) && (Number(settings.seekBarWidth) >= 0)) ? Number(settings.seekBarWidth) : 400;
			
			// time block
			_settings.displayTimeBlock			= ((settings.displayTimeBlock != null) && (settings.displayTimeBlock == "false")) ? false : true;
			_settings.timeBlockX				= ((settings.timeBlockX != null) && (Number(settings.timeBlockX) >= 0)) ? Number(settings.timeBlockX) : 0;
			_settings.timeBlockY				= ((settings.timeBlockY != null) && (Number(settings.timeBlockY) >= 0)) ? Number(settings.timeBlockY) : 0;
			_settings.timeBlockColor			= ((settings.timeBlockColor != null) && (Number(settings.timeBlockColor) >= 0)) ? Number(settings.timeBlockColor) : 0x000000;
			_settings.timeBlockBold				= ((settings.timeBlockBold != null) && (settings.timeBlockBold == "true")) ? true : false;
		}
		
		/**
		 * Listener for when the seek bar has been setup.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _seekBarReady(e:custom_event):void {
			_waitForSeekBar = false;
			_checkReady();
		}
		
		/**
		 * Listener for the seek change event.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _seekChanged(e:custom_event):void {
			dispatchEvent(new custom_event(VIDEO_SEEK, {value: e.params.value}));
		}
		
		/**
		 * Sets up the image loader object.
		 */
		private function _setupImageLoader():void {
			_imgLoader = new image_loader();
			_imgLoader.addEventListener(image_loader.IMAGE_LOADED, _imageLoaded, false, 0, true);
		}
		
		/**
		 * Lstener for the stop button's click event.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _stopButtonClick(e:custom_event):void {
			dispatchEvent(new custom_event(VIDEO_STOP));
			// check if the stop button exists, if so disable it
			if (_controls["stop_button"] != null) _disableButton(_controls["stop_button"].button);
			
			// check if the pause button exists, if so hide it - but, if the play button doesn't exist, just "disable" it
			if (_controls["pause_button"] != null) _disableButton(_controls["pause_button"].button, ((_controls["play_button"] == null) ? false : true));
			
			// check if the play button exists, if so enable it
			if (_controls["play_button"] != null) _enableButton(_controls["play_button"].button);
		}
		
		/**
		 * Listener for the volume button's click event.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _volumeButtonClick(e:custom_event):void {
			if (_controls["volume_slider"].enabled == false) {
				_controls["volume_slider"].enabled = true;
				_controls["volume_slider"].visible = true;
			} else {
				_controls["volume_slider"].enabled = false;
				_controls["volume_slider"].visible = false;
			}
		}
		
		/**
		 * Listener for the volume change event.
		 *
		 * @param custom_event e Event arguments.
		 */
		private function _volumeChanged(e:custom_event):void {
			dispatchEvent(new custom_event(VOLUME_CHANGE, {value: e.params.value}));
		}
	}
}