/**
 * Creates a random & rotating tag cloud.
 *
 * Usage: {{{
 *    var cloud:tag_cloud = new tag_cloud(cloud_settings);
 *    for (var i:int=1; i<=15; i++) {
 *    	cloud.addTag("Sample Tag #"+i, "http://www.google.com", "_self");
 *    }
 * }}}
 */

package classes {
	import classes.controls.tag;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class tag_cloud extends MovieClip {
		// Global vars
		public var PI:Number			= Math.PI;						// global holder for PI
		private var _diameter:Number	= new Number(300);				// diameter to rotate around
		private var _radius:Number		= new Number(_diameter / 2);	// half of the diameter... duh =P
		private var _settings:Object	= null;							// all current settings
		private var _tags:Array			= new Array();					// container for all of the tags
		private var _width:Number		= new Number(0);				// width of the cloud
		
		/**
		 * constructor: sets up the tag cloud
		 */
		public function tag_cloud(settings:Object):void {
			_settings = settings;			
			addEventListener(Event.ENTER_FRAME, _rotate, false);
		}
		
		/**
		 * add a tag to the current tag cloud
		 */
		public function addTag(txt:String, url:String=null, target:String=null):void {
			var settings:Object	= _settings;
			settings.text		= txt;
			settings.url		= url;
			settings.target		= target;
			var _tag:tag		= new tag(settings);
			
			// randomly position the tag
			var randX = Math.random() * 2 * PI;
			var randY = Math.random() * 2 * PI;
			_tag.x = _radius * Math.sin(randX) * Math.cos(randY);
			_tag.y = _radius * Math.sin(randX) * Math.sin(randY);
			_tag.z = _radius * Math.cos(randX);
			
			this.addChild(_tag);
			_tags.push(_tag);
		}
		
		/**
		 * spherically rotate the tags
		 */
		private function _rotate(e:Event):void {
			var x = Math.min(Math.max(this.mouseX, -(_diameter - (_diameter / 6))), (_diameter - (_diameter / 6))) / (_diameter / 2);
			var y = -Math.min(Math.max(this.mouseY, -(_diameter - (_diameter / 6))), (_diameter - (_diameter / 6))) / (_diameter / 2);
			
			var sx = Math.sin(x * 1.745329E-002);
			var cx = Math.cos(x * 1.745329E-002);
			var sy = Math.sin(y * 1.745329E-002);
			var cy = Math.cos(y * 1.745329E-002);
			var sin = Math.sin(0);
			var cos = Math.cos(0);
			
			for (var i=0; i<_tags.length; i++) {
				var y1 = _tags[i].y * cy + _tags[i].z * -sy;
				var y2 = _tags[i].y * sy + _tags[i].z * cy;
				var x1 = _tags[i].x * cx + y2 * sx;
				var z1 = _tags[i].x * -sx + y2 * cx;
				_tags[i].x = x1 * cos + x1 * -sin;
				_tags[i].y = y1 * sin + y1 * cos;
				_tags[i].z = z1;
				var mod = _diameter / (_diameter + z1);
				_tags[i].scaleX = _tags[i].scaleY = mod;
				_tags[i].alpha = .75 * mod;
			}
		}
	}
}