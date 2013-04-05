/**
 * Creates a managable and dynamic display for the different YouTube playlist data feeds.
 *
 * Usage {{{
 *    var settings:Object = new Object();
 *    // set any settings desired
 *    var playlist:youtube_playlist = new youtube_playlist(settings);
 *    playlist.addEventListener(youtube_playlist.PLAYLIST_READY, function (e:custom_event):void { addChild(playlist); }, false);
 *    playlist.addEventListener(youtube_playlist.PLAYLIST_SELECT, function (e:custom_event):void { trace("selected: " + e.params.id); }, false);
 *    playlist.load("http://gdata.youtube.com/feeds/api/users/watchtheguild/playlists");
 * }}}
 */

package classes.media.youtube {
	import classes.events.custom_event;
	import classes.file.image_loader;
	import classes.file.xml_loader;
	import classes.geom.simple_rectangle;
	import classes.text.text;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class youtube_playlist extends MovieClip {
		// Global vars
		public static var PLAYLIST_SELECT:String		= new String("playlistSelect");
		public static var PLAYLIST_READY:String			= new String("playlistReady");
		public static var TYPE_PLAYLIST:String			= new String("playlist");
		public static var TYPE_PLAYLISTS:String			= new String("playlistLink");
		public static var TYPE_VIDEO:String				= new String("video");
		private var app:Namespace						= new Namespace("http://purl.org/atom/app#");				// purl Atom Namespace
		private var atom:Namespace						= new Namespace("http://www.w3.org/2005/Atom");				// Atom / RSS Namespace
		private var gd:Namespace						= new Namespace("http://schemas.google.com/g/2005");		// Google Data Namespace
		private var media:Namespace						= new Namespace("http://search.yahoo.com/mrss/");			// Yahoo Search RSS/Media Namespace
		private var openSearch:Namespace				= new Namespace("http://a9.com/-/spec/opensearchrss/1.0/");	// Open Search RSS Namespace
		private var yt:Namespace						= new Namespace("http://gdata.youtube.com/schemas/2007");	// YouTube Data Namespace
		private var _currentItem:int					= -1;														// index of the currently selected item
		private var _imgLoader:image_loader				= null;														// global image loader object
		private var _playlist:Array						= null;														// array of all items in the playlist
		private var _settings:Object					= null;														// global object to hold all of the current settings
		private var _type:String						= null;														// current playlist type
		private var _xmlID:String						= new String("youtube_playlist_xml_id");					// ID to assign to the loading XML file
		private var _xmlLoader:xml_loader				= null;														// global xml loader object
		
		/**
		 * constructor: sets up the youtube_playlist
		 */
		public function youtube_playlist(settings:Object):void {
			_processSettings(settings);
			_setupImageLoader();
			_setupXMLLoader();
		}
		
		/**
		 * deselects all of the items in the list
		 */
		public function deselectAll():void {
			if (_playlist == null) return;
			for (var i:int=0; i<_playlist["entry"].length; i++) {
				if ((_settings.numberOfItems > 0) && ((i + 1) > _settings.numberOfItems)) break;
				// reset everything for the current item, thereby making it "unselected" if it's currently selected
				_playlist["entry"][i]["container"].alpha = _settings.itemAlpha;
				_playlist["entry"][i]["container"].getChildByName("backgroundUp").visible = true;
				_playlist["entry"][i]["container"].getChildByName("backgroundHover").visible = false;
				_playlist["entry"][i]["container"].getChildByName("backgroundSelected").visible = false;
			}
			_currentItem = -1;
		}
		
		/**
		 * checks if the current playlist has a next entry or not
		 */
		public function hasNext():Boolean {
			return ((_playlist != null) && (_playlist["entry"].length > 1)) ? true : false;
		}
		
		/**
		 * checks if the current playlist has a previous entry or not
		 */
		public function hasPrevious():Boolean {
			return ((_playlist != null) && (_playlist["entry"].length > 1)) ? true : false;
		}
		
		/**
		 * loads the specified XML file as a playlist
		 */
		public function load(url:String):void {
			if (numChildren > 0) {
				// we already have content (ie: a playlist) so we need to "disable" it first
				var overlay:simple_rectangle = new simple_rectangle(width, height, 0xffffff, 0, 0xffffff, 0);
				overlay.alpha = .1;
				overlay.mouseChildren = false;
				addChild(overlay);
			}
			_xmlLoader.load(url, _xmlID);
		}

		/**
		 * selects the next item in the list
		 */
		public function next():void {
			if (_playlist == null) return;
			var index:int = _currentItem + 1;
			if (index >= _playlist["entry"].length) index = 0;
			_selectItem(index);
		}

		/**
		 * returns the number of items for the currently loaded playlist
		 */
		public function numberOfItems():Number {
			return (_playlist == null) ? 0 : _playlist["entry"].length;
		}

		/**
		 * selects the previous item in the list
		 */
		public function previous():void {
			if (_playlist == null) return;
			var index:int = _currentItem - 1;
			if (index < 0) index = _playlist["entry"].length - 1;
			_selectItem(index);
		}

		/**
		 * builds a simple display for the given playlist item
		 */
		private function _buildItem(index:int):MovieClip {
			var container:MovieClip = new MovieClip();
			
			var thumbContainer:MovieClip = _createThumbnail(_playlist["entry"][index]["thumbnails"], index);
			if (thumbContainer != null) {
				thumbContainer.name = "thumbContainer";
				thumbContainer.y = _settings.itemPadding;
				thumbContainer.x = _settings.itemPadding;
				container.addChild(thumbContainer);
			}
			
			var contentContainer:MovieClip = new MovieClip();
			contentContainer.x		= (thumbContainer != null) ? (thumbContainer.x + thumbContainer.width + _settings.itemContentMargin) : _settings.itemPadding;
			contentContainer.y		= _settings.itemPadding;
			var contentWidth:Number	= (_settings.itemWidth - (_settings.itemPadding * 2) - ((thumbContainer != null) ? (thumbContainer.width - _settings.itemContentMargin) : 0) - (_settings.displayContentBackground ? (_settings.contentPadding * 2) : 0));
			
			var titleContainer:MovieClip = _createTitleText(_playlist["entry"][index]["title"], contentWidth);
			titleContainer.x = _settings.contentPadding;
			titleContainer.y = _settings.contentPadding;
			contentContainer.addChild(titleContainer);
			
			var descrContainer:MovieClip = _createDescriptionText(_playlist["entry"][index]["description"], contentWidth);
			if (descrContainer != null) {
				descrContainer.y = (titleContainer.y + titleContainer.height);
				descrContainer.x = _settings.contentPadding;
				contentContainer.addChild(descrContainer);
			}
			
			var numContainer:MovieClip = _createNumberOfVideosText(_playlist["entry"][index]["numberOfVideos"], contentWidth);
			if (numContainer != null) {
				numContainer.y = ((descrContainer != null) ? (descrContainer.y + descrContainer.height) : (titleContainer.y + titleContainer.height));
				numContainer.x = _settings.contentPadding;
				contentContainer.addChild(numContainer);
			}
			
			container.addChild(contentContainer);
			
			if (_settings.displayContentBackground) {
				var h:Number = (((thumbContainer != null) && (thumbContainer.height > container.height)) ? _settings.fullThumbnailHeight : container.height) + (_settings.contentPadding * 2);
				var contentBg:simple_rectangle = new simple_rectangle((contentWidth + (_settings.contentPadding * 2)), h, _settings.contentBackgroundColor, _settings.contentBackgroundBorderWidth, _settings.contentBackgroundBorderColor, 0);
				contentBg.x = (thumbContainer != null) ? (thumbContainer.x + _settings.fullThumbnailWidth + _settings.itemContentMargin) : _settings.itemPadding;
				contentBg.y = _settings.itemPadding;
				container.addChildAt(contentBg, 0);
				
				titleContainer.x += _settings.contentPadding;
				titleContainer.y += _settings.contentPadding;
				if (descrContainer != null) {
					descrContainer.x += _settings.contentPadding;
					descrContainer.y += _settings.contentPadding;
				}
				if (numContainer != null) {
					numContainer.x += _settings.contentPadding;
					numContainer.y += _settings.contentPadding;
				}
			}
			
			return container;
		}

		/**
		 * builds the playlist, item by item
		 */
		private function _buildPlaylist():void {
			// incase we already have a playlist loaded, remove all children - the G.C. should take care of listeners (hopefully)
			if (numChildren > 0) {
				getChildAt((numChildren - 1)).alpha = .6;
				while (numChildren > 0) removeChildAt(0);
			}
		
			for (var i:int=0; i<_playlist["entry"].length; i++) {
				if ((_settings.numberOfItems > 0) && ((i + 1) > _settings.numberOfItems)) break; // reached the limit to display
				
				var container:MovieClip = _buildItem(i);
				container.name = String(i);

				_setupContainerButton(container, i, (container.getChildByName("thumbContainer") != null));
				_playlist["entry"][i]["container"] = container;
				
				container.y = (i == 0) ? 0 : (getChildAt(numChildren - 1).y + getChildAt(numChildren - 1).height + _settings.itemMargin);
				container.alpha = _settings.itemAlpha;
				
				addChild(container);
			}
			
			dispatchEvent(new custom_event(PLAYLIST_READY));
			_selectItem(0);
		}

		/**
		 * creates the description text block
		 */
		private function _createDescriptionText(str:String, maxWidth:Number):MovieClip {
			var descrContainer:MovieClip = null;
			if (_settings.displayDescription && (str != "")) {
				descrContainer	= new MovieClip();
				var descr:text	= new text(str, descrContainer);
				descr.size		= _settings.itemFontSize;
				descr.color		= _settings.itemColor;
				descr.width		= maxWidth;
				descr.wordWrap	= true;
			}
			return descrContainer;
		}

		/**
		 * creates the number of videos text block
		 */
		private function _createNumberOfVideosText(str:String, maxWidth:Number):MovieClip {
			var numContainer:MovieClip = null;
			if ((_type == TYPE_PLAYLISTS) && _settings.displayPlaylistNumberOfVideos) {
				numContainer	= new MovieClip();
				var num:text	= new text("Videos: " + str, numContainer);
				num.size		= _settings.itemFontSize;
				num.color		= _settings.itemColor;
				num.width		= maxWidth;
			}
			return numContainer;
		}

		/**
		 * creates the thumbnail block
		 */
		private function _createThumbnail(thumbnails:Array, thumbId:int):MovieClip {
			var thumbContainer:MovieClip = null;
			if ((_type == TYPE_PLAYLIST) && _settings.displayThumbnail && (thumbnails.length > 0)) {
				thumbContainer = new MovieClip();
				
				var thumb:MovieClip = new MovieClip();
				var thumbBg:simple_rectangle = new simple_rectangle(_settings.fullThumbnailWidth, _settings.fullThumbnailHeight, _settings.thumbnailBackgroundColor, _settings.thumbnailBackgroundBorderWidth, _settings.thumbnailBackgroundBorderColor, 0);
				thumbContainer.addChild(thumbBg);
				if (!_settings.displayThumbnailBackground) {
					thumbBg.alpha = .001;
				} else {
					thumb.x = _settings.thumbnailPadding;
					thumb.y = _settings.thumbnailPadding;
				}
				
				_imgLoader.load(thumbnails[0]["image"], thumb, "playlistThumb" + thumbId);
				thumbContainer.addChild(thumb);
			}
			return thumbContainer;
		}

		/**
		 * creates the title text block
		 */
		private function _createTitleText(str:String, maxWidth:Number):MovieClip {
			var titleContainer:MovieClip = new MovieClip();
			var title:text	= new text(str, titleContainer);
			title.size		= _settings.itemTitleFontSize;
			title.color		= _settings.itemTitleColor;
			title.bold		= _settings.itemTitleBold;
			title.wordWrap	= _settings.itemTitleWordWrap;
			title.width		= maxWidth;
			return titleContainer;
		}

		/**
		 * handles a loaded image by resizing it; needs to be resized after it loads, otherwise it won't resize properly
		 */
		private function _imageLoaded(e:custom_event):void {
			if ((e.params.id.length > 13) && (e.params.id.substr(0, 13) == "playlistThumb")) {
				e.params.container.width = _settings.thumbnailWidth;
				e.params.container.height = _settings.thumbnailHeight;
			}
		}

		/**
		 * parses the loaded XML data to build the playlist
		 */
		private function _parseData(data:XML):void {
			_playlist = new Array();
			
			default xml namespace = atom;
			if (_type == TYPE_PLAYLIST) _playlist["title"] = data.title.toString();
			
			_playlist["entry"] = new Array();
			var i:int = 0;
			
			for each (var entry:XML in data..entry) {
				if ((_settings.numberOfItems > 0) && ((i + 1) > _settings.numberOfItems)) break; // reached the limit to display

				_playlist["entry"][i] = new Array();
				_playlist["entry"][i]["title"] = entry.title.toString();
				_playlist["entry"][i]["description"] = "";
				
				if (_type == TYPE_PLAYLISTS) {
					// http://gdata.youtube.com/feeds/api/users/USER_NAME/playlists
					// viewing a list of playlists for a user
					_playlist["entry"][i]["playlistUrl"] = entry.gd::feedLink.@href;
					_playlist["entry"][i]["numberOfVideos"] = entry.gd::feedLink.@countHint;
					_playlist["entry"][i]["description"] = entry.yt::description.toString();
				} else if (_type == TYPE_PLAYLIST) {
					// http://gdata.youtube.com/feeds/api/playlists/PLAYLIST_ID
					// viewing a list of all videos inside of a playlist (ie: viewing a playlist)
					_playlist["entry"][i]["description"] = (entry.content != null) ? entry.content.toString() : "";
					_playlist["entry"][i]["thumbnails"] = new Array();
					var t:int = 0;
					
					// parse all of the thumbnails
					var mediaGroup:XMLList = entry.media::group;
					for each (var thumb:XML in mediaGroup.media::thumbnail) {
						_playlist["entry"][i]["thumbnails"][t] = new Array();
						_playlist["entry"][i]["thumbnails"][t]["image"] = thumb.@url;
						_playlist["entry"][i]["thumbnails"][t]["width"] = thumb.@width;
						_playlist["entry"][i]["thumbnails"][t]["height"] = thumb.@height;
						t++;
					}
					
					_playlist["entry"][i]["videoUrl"] = "";
					for each (var vids:XML in mediaGroup.media::content) {
						// check each video for the default one
						if (vids.@isDefault == "true") _playlist["entry"][i]["videoUrl"] = vids.@url;
					}
					if (_playlist["entry"][i]["videoUrl"] != "") {
						// for TYPE_PLAYLIST, we are given a /v/ID?query, but we don't want the query string (actaully doesn't matter, but whatever =P)
						_playlist["entry"][i]["videoUrl"] = (_playlist["entry"][i]["videoUrl"]).substr(0, (_playlist["entry"][i]["videoUrl"]).indexOf("?"));
					}
				} else if (_type == TYPE_VIDEO) {
					// http://gdata.youtube.com/feeds/base/users/USER_NAME/uploads
					// viewing a list of all UPLOADS by a user
					_playlist["entry"][i]["description"] = (entry.content != null) ? entry.content.toString() : "";
					
					_playlist["entry"][i]["videoUrl"] = (entry.id != null) ? entry.id.toString() : "";
					if (_playlist["entry"][i]["videoUrl"] != "") {
						// for "uploads", we are given a typical youtube.com/watch?v=ID, we want /v/ID so parse the given URL!
						_playlist["entry"][i]["videoUrl"] = "http://www.youtube.com/v/" + _playlist["entry"][i]["videoUrl"].substr(_playlist["entry"][i]["videoUrl"].lastIndexOf("/") + 1);
					}
				}
				i++;
			}
			
			_buildPlaylist();
		}

		/**
		 * processes all specified settings and defines their default values
		 */
		private function _processSettings(settings:Object):void {
			_settings = new Object();
			
			_settings.displayContentBackground		= ((settings.displayContentBackground != null) && (settings.displayContentBackground == "true")) ? true : false;
			_settings.displayThumbnail				= ((settings.displayThumbnail != null) && (settings.displayThumbnail == "true")) ? true : false;
			_settings.displayThumbnailBackground	= (_settings.displayThumbnail && (settings.displayThumbnailBackground != null) && (settings.displayThumbnailBackground == "true")) ? true : false;
			_settings.displayDescription			= ((settings.displayDescription != null) && (settings.displayDescription == "true")) ? true : false;
			_settings.displayPlaylistNumberOfVideos	= ((settings.displayPlaylistNumberOfVideos != null) && (settings.displayPlaylistNumberOfVideos == "true")) ? true : false;
			_settings.numberOfItems					= ((settings.numberOfItems != null) && (Number(settings.numberOfItems) > 0)) ? Number(settings.numberOfItems) : 0;

			// full item
				// -- regular
				_settings.itemAlpha				= ((settings.itemAlpha != null) && (Number(settings.itemAlpha) >= 0)) ? Number(settings.itemAlpha) : 1;
				_settings.itemBorderWidth		= ((settings.itemBorderWidth != null) && (Number(settings.itemBorderWidth) >= 0)) ? Number(settings.itemBorderWidth) : 1;
				_settings.itemBorderColor		= ((settings.itemBorderColor != null) && (Number(settings.itemBorderColor) >= 0)) ? Number(settings.itemBorderColor) : 0x000000;
				_settings.itemBackgroundColor	= ((settings.itemBackgroundColor != null) && (Number(settings.itemBackgroundColor) >= 0)) ? Number(settings.itemBackgroundColor) : 0x000000;
				_settings.itemBackgroundAlpha	= ((settings.itemBackgroundAlpha != null) && (Number(settings.itemBackgroundAlpha) >= 0)) ? Number(settings.itemBackgroundAlpha) : 1;
				// -- hover
				_settings.itemAlphaHover			= ((settings.itemAlphaHover != null) && (Number(settings.itemAlphaHover) >= 0)) ? Number(settings.itemAlphaHover) : _settings.itemAlpha;
				_settings.itemBorderWidthHover		= ((settings.itemBorderWidthHover != null) && (Number(settings.itemBorderWidthHover) >= 0)) ? Number(settings.itemBorderWidthHover) : _settings.itemBorderWidth;
				_settings.itemBorderColorHover		= ((settings.itemBorderColorHover != null) && (Number(settings.itemBorderColorHover) >= 0)) ? Number(settings.itemBorderColorHover) : _settings.itemBorderColor;
				_settings.itemBackgroundColorHover	= ((settings.itemBackgroundColorHover != null) && (Number(settings.itemBackgroundColorHover) >= 0)) ? Number(settings.itemBackgroundColorHover) : _settings.itemBackgroundColor;
				_settings.itemBackgroundAlphaHover	= ((settings.itemBackgroundAlphaHover != null) && (Number(settings.itemBackgroundAlphaHover) >= 0)) ? Number(settings.itemBackgroundAlphaHover) : _settings.itemBackgroundAlpha;
				// -- selected
				_settings.itemAlphaSelected				= ((settings.itemAlphaSelected != null) && (Number(settings.itemAlphaSelected) >= 0)) ? Number(settings.itemAlphaSelected) : _settings.itemAlpha;
				_settings.itemBorderWidthSelected		= ((settings.itemBorderWidthSelected != null) && (Number(settings.itemBorderWidthSelected) >= 0)) ? Number(settings.itemBorderWidthSelected) : _settings.itemBorderWidth;
				_settings.itemBorderColorSelected		= ((settings.itemBorderColorSelected != null) && (Number(settings.itemBorderColorSelected) >= 0)) ? Number(settings.itemBorderColorSelected) : _settings.itemBorderColor;
				_settings.itemBackgroundColorSelected	= ((settings.itemBackgroundColorSelected != null) && (Number(settings.itemBackgroundColorSelected) >= 0)) ? Number(settings.itemBackgroundColorSelected) : _settings.itemBackgroundColor;
				_settings.itemBackgroundAlphaSelected	= ((settings.itemBackgroundAlphaSelected != null) && (Number(settings.itemBackgroundAlphaSelected) >= 0)) ? Number(settings.itemBackgroundAlphaSelected) : _settings.itemBackgroundAlpha;
				// -- not change-able
				_settings.itemContentMargin	= ((settings.itemContentMargin != null) && (Number(settings.itemContentMargin) >= 0)) ? Number(settings.itemContentMargin) : 5;
				_settings.itemMargin		= ((settings.itemMargin != null) && (Number(settings.itemMargin) >= 0)) ? Number(settings.itemMargin) : 0;
				_settings.itemPadding		= ((settings.itemPadding != null) && (Number(settings.itemPadding) >= 0)) ? Number(settings.itemPadding) : 5;
				_settings.itemWidth			= ((settings.itemWidth != null) && (Number(settings.itemWidth) > (_settings.itemPadding * 2))) ? Number(settings.itemWidth) : 275;
				_settings.itemTextWidth		= (_settings.itemWidth - (_settings.itemPadding * 2));
			
			// content background
			if (_settings.displayContentBackground == true) {
				_settings.contentBackgroundBorderWidth	= ((settings.contentBackgroundBorderWidth != null) && (Number(settings.contentBackgroundBorderWidth) >= 0)) ? Number(settings.contentBackgroundBorderWidth) : 1;
				_settings.contentBackgroundBorderColor	= ((settings.contentBackgroundBorderColor != null) && (Number(settings.contentBackgroundBorderColor) >= 0)) ? Number(settings.contentBackgroundBorderColor) : 0x000000;
				_settings.contentBackgroundColor		= ((settings.contentBackgroundColor != null) && (Number(settings.contentBackgroundColor) >= 0)) ? Number(settings.contentBackgroundColor) : 0x000000;
				_settings.contentPadding				= ((settings.contentPadding != null) && (Number(settings.contentPadding) >= 0)) ? Number(settings.contentPadding) : 3;
			}
			
			// title settings
			_settings.itemTitleFontSize	= ((settings.itemTitleFontSize != null) && (Number(settings.itemTitleFontSize) >= 10)) ? Number(settings.itemTitleFontSize) : 10;
			_settings.itemTitleColor	= ((settings.itemTitleColor != null) && (Number(settings.itemTitleColor) >= 0)) ? Number(settings.itemTitleColor) : 0x000000;
			_settings.itemTitleBold		= ((settings.itemTitleBold != null) && (settings.itemTitleBold == "true")) ? true : false;
			_settings.itemTitleWordWrap	= ((settings.itemTitleWordWrap != null) && (settings.itemTitleWordWrap == "true")) ? true : false;
			
			// regular font settings
			_settings.itemFontSize	= ((settings.itemFontSize != null) && (Number(settings.itemFontSize) >= 10)) ? Number(settings.itemFontSize) : 10;
			_settings.itemColor		= ((settings.itemColor != null) && (Number(settings.itemColor) >= 0)) ? Number(settings.itemColor) : 0x000000;
			
			_settings.thumbnailWidth = ((settings.thumbnailWidth != null) && (Number(settings.thumbnailWidth) >= 0)) ? Number(settings.thumbnailWidth) : 120;
			_settings.thumbnailHeight = ((settings.thumbnailHeight != null) && (Number(settings.thumbnailHeight) >= 0)) ? Number(settings.thumbnailHeight) : 90;
			
			// thumbnail background
			if (_settings.displayThumbnailBackground == true) {
				_settings.thumbnailBackgroundBorderWidth	= ((settings.thumbnailBackgroundBorderWidth != null) && (Number(settings.thumbnailBackgroundBorderWidth) >= 0)) ? Number(settings.thumbnailBackgroundBorderWidth) : 1;
				_settings.thumbnailBackgroundBorderColor	= ((settings.thumbnailBackgroundBorderColor != null) && (Number(settings.thumbnailBackgroundBorderColor) >= 0)) ? Number(settings.thumbnailBackgroundBorderColor) : 0x000000;
				_settings.thumbnailBackgroundColor			= ((settings.thumbnailBackgroundColor != null) && (Number(settings.thumbnailBackgroundColor) >= 0)) ? Number(settings.thumbnailBackgroundColor) : 0x000000;
				_settings.thumbnailPadding					= ((settings.thumbnailPadding != null) && (Number(settings.thumbnailPadding) >= 0)) ? Number(settings.thumbnailPadding) : 3;
				_settings.fullThumbnailWidth				= (_settings.thumbnailWidth + (_settings.thumbnailPadding * 2));
				_settings.fullThumbnailHeight				= (_settings.thumbnailHeight + (_settings.thumbnailPadding * 2));
			} else {
				_settings.fullThumbnailWidth				= _settings.thumbnailWidth;
				_settings.fullThumbnailHeight				= _settings.thumbnailHeight;
			}
		}

		/**
		 * hilights, if styles permit, the given container and dispatches a PLAYLIST_SELECT event
		 */
		private function _selectItem(index:int):void {
			// check if the index is valid, or if it's not already selected (no need to re-select it!)
			if ((index >= 0) && (_playlist["entry"].length > index) && (_currentItem != index)) {
				_currentItem = index;
				
				for (var i:int=0; i<_playlist["entry"].length; i++) {
					if ((_settings.numberOfItems > 0) && ((i + 1) > _settings.numberOfItems)) break;
					if (i == index) {
						// "select" the item specified
						_playlist["entry"][i]["container"].alpha = _settings.itemAlphaSelected;
						_playlist["entry"][i]["container"].getChildByName("backgroundUp").visible = false;
						_playlist["entry"][i]["container"].getChildByName("backgroundHover").visible = false;
						_playlist["entry"][i]["container"].getChildByName("backgroundSelected").visible = true;
					} else {
						// reset everything for the current item, thereby making it "unselected" if it's currently selected
						_playlist["entry"][i]["container"].alpha = _settings.itemAlpha;
						_playlist["entry"][i]["container"].getChildByName("backgroundUp").visible = true;
						_playlist["entry"][i]["container"].getChildByName("backgroundHover").visible = false;
						_playlist["entry"][i]["container"].getChildByName("backgroundSelected").visible = false;
					}
				}

				// dispatch an event to any listener to tell them which item we've selected
				dispatchEvent(new custom_event(PLAYLIST_SELECT, {id: index, type: _type, url: ((_type == TYPE_PLAYLISTS) ? _playlist["entry"][index]["playlistUrl"] : _playlist["entry"][index]["videoUrl"]), container: _buildItem(index)}));
			}
		}

		/**
		 * sets up the background visuals and the "button mode" for the given container
		 */
		private function _setupContainerButton(container:MovieClip, index:int, thumbnailLoaded:Boolean):void {
			var h:Number = ((thumbnailLoaded && (_settings.fullThumbnailHeight > container.height)) ? _settings.fullThumbnailHeight : container.height) + (_settings.itemPadding * 2);
			
			// create the UP state of the background
			var bgUp:simple_rectangle = new simple_rectangle(_settings.itemWidth, h, _settings.itemBackgroundColor, _settings.itemBorderWidth, _settings.itemBorderColor, 0);
			bgUp.alpha = _settings.itemBackgroundAlpha;
			bgUp.visible = true;
			bgUp.name = "backgroundUp";
			container.addChildAt(bgUp, 0);
			
			// create the OVER state of the background
			var bgHover:simple_rectangle = new simple_rectangle(_settings.itemWidth, h, _settings.itemBackgroundColorHover, _settings.itemBorderWidthHover, _settings.itemBorderColorHover, 0);
			bgHover.alpha = _settings.itemBackgroundAlphaHover;
			bgHover.visible = false;
			bgHover.name = "backgroundHover";
			container.addChildAt(bgHover, 0);
			
			// create the selected state of the background
			var bgSelected:simple_rectangle = new simple_rectangle(_settings.itemWidth, h, _settings.itemBackgroundColorSelected, _settings.itemBorderWidthSelected, _settings.itemBorderColorSelected, 0);
			bgSelected.alpha = _settings.itemBackgroundAlphaSelected;
			bgSelected.visible = false;
			bgSelected.name = "backgroundSelected";
			container.addChildAt(bgSelected, 0);
			
			// setup the general button effects for the container
			container.buttonMode = true;
			container.useHandCursor = true;
			
			// create the ON_CLICK listener for the container, making it select the item
			container.addEventListener(MouseEvent.CLICK,
				function (e:MouseEvent):void {
					_selectItem(index);
				},
				false
			);
			
			// create the MOUSE_OVER listener for the container, making it highlight
			container.addEventListener(MouseEvent.MOUSE_OVER,
				function (e:MouseEvent):void {
					if (_currentItem == index) return;
					
					container.alpha = _settings.itemAlphaHover;
					container.getChildByName("backgroundUp").visible = false;
					container.getChildByName("backgroundHover").visible = true;
					container.getChildByName("backgroundSelected").visible = false;
				},
				false
			);
			
			// create the MOUSE_OUT listener for the container, making it unhighlight
			container.addEventListener(MouseEvent.MOUSE_OUT,
				function (e:MouseEvent):void {
					if (_currentItem == index) return;
					container.alpha = _settings.itemAlpha;
					container.getChildByName("backgroundUp").visible = true;
					container.getChildByName("backgroundHover").visible = false;
					container.getChildByName("backgroundSelected").visible = false;
				},
				false
			);
		}
		
		/**
		 * create the image loader and add all necessary listeners to it
		 */
		private function _setupImageLoader():void {
			_imgLoader = new image_loader();
			_imgLoader.addEventListener(image_loader.IMAGE_LOADED, _imageLoaded, false);
		}
		
		/**
		 * create the xml loader and add all necessary listeners to it
		 */
		private function _setupXMLLoader():void {
			_xmlLoader = new xml_loader();
			_xmlLoader.addEventListener(xml_loader.FILE_LOADED,			_xmlComplete,	false);
			_xmlLoader.addEventListener(xml_loader.IO_ERROR,			_xmlError,		false);
			_xmlLoader.addEventListener(xml_loader.SECURITY_ERROR,		_xmlError,		false);
			_xmlLoader.addEventListener(xml_loader.TYPE_ERROR,			_xmlError,		false);
		}
		
		/**
		 * a xml file has been loaded
		 */
		private function _xmlComplete(e:custom_event):void {
			if (e.params.id == _xmlID) {
				trace("[youtube_playlist] The xml file has been loaded.");
				
				// grab a copy of the loaded XML data
				var data:XML = new XML(e.params.data);

				// setup the atom namespace, otherwise we need to add namespace to every node parsed
				default xml namespace = atom;
				if (_xmlLoader.isEmpty(data.category, true) || !("@term" in data.category)) {
					trace("[youtube_playlist] Invalid XML file. No category present.");
					return;
				}
				
				var term:String = data.category.@term;
				_type = term.substr(term.indexOf('#') + 1);
				
				_parseData(data);
			}
		}

		/**
		 * an error has occurred on the current xml file
		 */
		private function _xmlError(e:custom_event):void {
			trace("[youtube_playlist] There was an error loading the XML file.");
			
		}
	}
}