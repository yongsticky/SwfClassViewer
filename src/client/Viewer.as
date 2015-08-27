package client
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	

	public class Viewer extends Sprite
	{
		[Embed(source="../../resource/btn.png")]
		private static const ButtonBkgTexture:Class;
		
		[Embed(source="../../resource/left.png")]
		private static const LeftArrowTexture:Class;
		
		[Embed(source="../../resource/right.png")]
		private static const RightArrowTexture:Class;
		
		
		private var _selectButton:Button;
		private var _rightButton:Button;
		private var _leftButton:Button;
		private var _itemView:Sprite;
		private var _presentTextfield:TextField;
		
		private var _bmdArr:Array = null;
				
		private var _nextImageIndex:int = 0;
		
		public function Viewer()
		{
			stage ? initialize():addEventListener(starling.events.Event.ADDED_TO_STAGE, function (event:starling.events.Event) : void {
				event.target.removeEventListener(starling.events.Event.ADDED_TO_STAGE, arguments.callee);
				initialize();
			});
		}
		
		public function initialize() : void
		{	
			_bmdArr = new Array();
			
			// 查看
			addItemView();
			
			// 文字介绍
			addTextPresent();
			
			// 选择按钮
			addSelectButton();
			
			// 左右切换按钮
			addArrow();			
		}
		
		private function addItemView() : void
		{
			_itemView = new Sprite();
			
			_itemView.width = 480;
			_itemView.height = 400;
			
			_itemView.x = (stage.stageWidth - _itemView.width) >> 1;
			_itemView.y = 80;
			
			addChild(_itemView);
		}
		
		private function addTextPresent() : void
		{
			_presentTextfield = new TextField(400, 25, "this is present text.");
			
			_presentTextfield.x = (stage.stageWidth - _presentTextfield.width) >> 1;
			_presentTextfield.y = 40;					
			_presentTextfield.bold = true;			
			
			addChild(_presentTextfield);			
		}
		
		private function addSelectButton() : void
		{
			var t:Texture = Texture.fromBitmap(new ButtonBkgTexture());
			
			_selectButton = new Button(t, "选择SWF文件");
			_selectButton.width = 247;
			_selectButton.height = 58;
			
			_selectButton.x = (stage.stageWidth - _selectButton.width) >> 1;
			_selectButton.y = stage.stageHeight - _selectButton.height - 40;
			
			_selectButton.addEventListener(TouchEvent.TOUCH, onTouchSelect);
			
			addChild(_selectButton);
		}
		
		private function addArrow() : void
		{
			var tl:Texture = Texture.fromBitmap(new LeftArrowTexture());			
			_leftButton = new Button(tl, "");
			
			
			var tr:Texture = Texture.fromBitmap(new RightArrowTexture());			
			_rightButton = new Button(tr, "");
			
			_leftButton.width = _rightButton.width = 119;
			_leftButton.height = _rightButton.height = 120;
			
			_leftButton.x = 20;
			_rightButton.x = stage.stageWidth - _rightButton.width - 20;
			_leftButton.y = _rightButton.y = (stage.stageHeight - _leftButton.height) >> 1;
			
			_leftButton.addEventListener(TouchEvent.TOUCH, onTouchLeft);
			_leftButton.addEventListener(TouchEvent.TOUCH, onTouchRight);
			
			
			addChild(_leftButton);
			addChild(_rightButton);
			
		}
		
		private function onTouchLeft(event:TouchEvent):void
		{			
			showNext();
		}
		
		private function onTouchRight(event:TouchEvent):void
		{			
			showPrev();
		}
		
		private function onTouchSelect(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_selectButton);
			if (touch)
			{
				if (touch.phase == TouchPhase.ENDED)
				{
					var f:File = new File();
					f.browseForOpen("请选择SWF文件", [new FileFilter("Shock Wave Flash", "*.swf")]);
					f.addEventListener(flash.events.Event.SELECT, onSelectSwf);
				}
			}
		}
		
		
		protected function onSelectSwf(event:flash.events.Event):void
		{
			var f:File = event.target as File;
			if (f)
			{			
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, onLoadSwfComplete);
				loader.contentLoaderInfo.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				loader.contentLoaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR, onIoError);
				loader.load(new URLRequest(f.nativePath));
			}
		}
		
		protected function onLoadSwfComplete(event:flash.events.Event) : void
		{	
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;			
			var clsVec:Vector.<String> = SwfUtil.getSWFClassName(loaderInfo.bytes);
			for each(var clsName:String in clsVec)
			{
				var cls:Class = Object(loaderInfo).applicationDomain.getDefinition(clsName);
				_bmdArr.push(new cls());				
			}
			
			showNext();
		}
		
		protected function onIoError(event:IOErrorEvent):void
		{
			trace("io error");
		}
		
		protected function onSecurityError(event:SecurityErrorEvent):void
		{
			trace("security error");			
		}	
		
		
		protected function showNext() : void
		{
			if (_nextImageIndex >= _bmdArr.length)
			{
				_nextImageIndex = 0;
			}
					
			
			var t:Texture = Texture.fromBitmapData(_bmdArr[_nextImageIndex++]);
			
			if (_itemView.numChildren)
			{
				_itemView.removeChildAt(0, true);
			}
			
			_itemView.addChild(new Image(t));			
			
		}
		
		protected function showPrev() : void
		{			
			
		}
		
		
		
		
		
		
	}
}