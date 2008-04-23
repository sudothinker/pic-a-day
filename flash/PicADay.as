package
{
  import com.dynamicflash.util.Base64;

  import flash.display.Sprite;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.events.*;
  import flash.external.ExternalInterface;
  import flash.media.Camera;
  import flash.media.Video;
  import flash.utils.Timer;
  import flash.utils.ByteArray;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.text.TextField;
  import flash.text.TextFormat;
  
  public class PicADay extends Sprite
  {
    private var fb_user_id:String;
    private var user_hash:String;

    private var video_container:Sprite;
    private var _video:Video;
    private var _save:Sprite;
    private var _redo:Sprite;
    private var _take:Sprite;
    private var _countdown_display:TextField;
    private var _overlay:Sprite;
    private var _temp_capture:Sprite;
    
    private var _capture_timer:Timer;
    
    private var _bitmap_container:BitmapData;
    
    private const DEFAULT_CAPTURE_HANGTIME:Number = 1000;
    private const DEFAULT_CAMERA_WIDTH:int = 480;
    private const DEFAULT_CAMERA_HEIGHT:int = 360;
    private const DEFAULT_CAMERA_FPS:Number = 25;
    private const DEFAULT_MARGIN:Number = 8;
    private const DEFAULT_COUNT_DOWN:int = 3;
    private const DEFAULT_COUNT_DOWN_INTERVAL:Number = 1000;
    
    public function PicADay()
    {
      presets();
      init();
    }
    
    private function presets():void
    {
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;
    }
     
    private function init():void
    { 
      video_container = new Sprite();
      _overlay = new Sprite();
      _temp_capture = new Sprite();
      _countdown_display = new TextField();
      var display_format:TextFormat = new TextFormat("_sans", 24, 0xffffff);
      display_format.align = "center";
      _countdown_display.defaultTextFormat = display_format;
      _countdown_display.autoSize = "center";
      _countdown_display.wordWrap = true;
      _countdown_display.selectable = false;
      this.drawUI();
      this.addChild(video_container);
      this.addChild(_take);
      var camera:Camera = Camera.getCamera("2");
      
      if (camera != null)
      {
        camera.addEventListener(ActivityEvent.ACTIVITY, activityHandler);
        camera.setMode(this.DEFAULT_CAMERA_WIDTH, this.DEFAULT_CAMERA_HEIGHT, this.DEFAULT_CAMERA_FPS);
        _video = new Video(this.DEFAULT_CAMERA_WIDTH, this.DEFAULT_CAMERA_HEIGHT);
        _video.smoothing = true;
        _video.attachCamera(camera);
        _video.scaleX = -1;
        video_container.addChild(_video);
        video_container.addChild(_overlay);
        video_container.addChild(_temp_capture);
        drawOverlay();
      }
      else
      {
        trace("You need a camera.");
      }
      stage.addEventListener(Event.RESIZE, resize);
      _take.addEventListener(MouseEvent.CLICK, startCapture);
      this.resize();
    }

    private function drawUI():void
    {
      _take = new Sprite();
      _save = new Sprite();
      _redo = new Sprite();
      _take.mouseChildren = false;
      _save.mouseChildren = false;
      _redo.mouseChildren = false;
      var button_text_format:TextFormat = new TextFormat("_sans",12,0xffffff);
      button_text_format.align = "center";
      var take_text:TextField = new TextField();
      take_text.defaultTextFormat = button_text_format;
      take_text.autoSize = "center";
      take_text.text = "take\npicture";
      take_text.selectable = false;
      var save_text:TextField = new TextField();
      save_text.defaultTextFormat = button_text_format;
      save_text.autoSize = "center";
      save_text.text = "save";
      save_text.selectable = false;
      var redo_text:TextField = new TextField();
      redo_text.defaultTextFormat = button_text_format;
      redo_text.autoSize = "center";
      redo_text.text = "retake";
      redo_text.selectable = false;
      
      
      _take.graphics.lineStyle(1,0x888888, 0.5, true);
      _take.graphics.beginFill(0x000000, 0.75);
      _take.graphics.drawRoundRect(0,0,64,64,8,8);
      _take.graphics.endFill();
      take_text.width = _save.width;
      take_text.x = (_take.width - take_text.width)/2;
      take_text.y = -2 + (_take.height - take_text.height)/2;
      _take.addChild(take_text);
      _take.addEventListener(MouseEvent.CLICK, startCapture);
      _take.useHandCursor = _take.buttonMode = true;
      
      _save.graphics.lineStyle(1,0x888888, 0.5, true);
      _save.graphics.beginFill(0x006600, 0.75);
      _save.graphics.drawRoundRect(0,0,64,64,8,8);
      _save.graphics.endFill();
      save_text.width = _save.width;
      save_text.x = (_save.width - save_text.width)/2;
      save_text.y = (_save.height - save_text.height)/2;
      _save.addChild(save_text);
      _save.addEventListener(MouseEvent.CLICK, saveCapture);
      _save.useHandCursor = _save.buttonMode = true;
      
      _redo.graphics.lineStyle(1,0x888888, 0.5, true);
      _redo.graphics.beginFill(0x440000, 0.75);
      _redo.graphics.drawRoundRect(0,0,64,64,8,8);
      _redo.graphics.endFill();
      redo_text.width = _redo.width;
      redo_text.x = (_redo.width - redo_text.width)/2;
      redo_text.y = (_redo.height - redo_text.height)/2;
      _redo.addChild(redo_text);
      _redo.addEventListener(MouseEvent.CLICK, clearCapture);
      _redo.useHandCursor = _redo.buttonMode = true;
      
    }
    
    private function startCapture(e:Event):void
    {
      _capture_timer = new Timer(this.DEFAULT_COUNT_DOWN_INTERVAL, this.DEFAULT_COUNT_DOWN);
      _capture_timer.addEventListener(TimerEvent.TIMER, onCaptureTimer);
      _capture_timer.addEventListener(TimerEvent.TIMER_COMPLETE, capture);
      _capture_timer.start();
      _take.visible = false;
      this.onCaptureTimer();
      this.addChild(_countdown_display);
      
    }
    
    private function onCaptureTimer(e:TimerEvent=null):void
    {
      var count_down:int = (this.DEFAULT_COUNT_DOWN-this._capture_timer.currentCount);
      _countdown_display.text = String(count_down);
      //_countdown_display.scaleX *= stage.stageWidth/_countdown_display.width;
      _countdown_display.scaleX = _countdown_display.scaleY *= stage.stageHeight/_countdown_display.height;
      _countdown_display.x = (stage.stageWidth-_countdown_display.width)/2;
      _countdown_display.y = (stage.stageHeight-_countdown_display.height)/2;
    }
    
    private function capture(e:Event):void
    {
      this.removeChild(_countdown_display);
      _capture_timer.removeEventListener(TimerEvent.TIMER, onCaptureTimer);
      _capture_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, capture);
      video_container.useHandCursor = video_container.buttonMode = false;
      _bitmap_container = new BitmapData(_video.width, _video.height);
      _bitmap_container.draw(_video);
      _temp_capture.graphics.clear();
      _temp_capture.graphics.beginBitmapFill(_bitmap_container,null,false,true);
      _temp_capture.graphics.drawRect(0,0,_video.width, _video.height);
      _temp_capture.graphics.endFill();
      _temp_capture.scaleX = -1;
      _temp_capture.visible = true;
      this.addChild(_save);
      this.addChild(_redo);
    }
    
    private function clearCapture(e:Event):void
    {
      this.reset();
    }
    
    private function saveCapture(e:Event):void
    {
      var png:ByteArray = convertToPNG(_bitmap_container);
      png.position = 0;
      var service:URLLoader = new URLLoader();
      service.dataFormat = "binary";
            
      this.fb_user_id = root.loaderInfo.parameters['fb_user_id']
      this.user_hash = root.loaderInfo.parameters['user_hash']
            
      var serviceGateway:URLRequest = new URLRequest('http://pseudothinker.com/capture');
      serviceGateway.method = "POST";
      serviceGateway.data = this.fb_user_id + "|" + this.user_hash + "|" + Base64.encodeByteArray(png);
      service.addEventListener(Event.COMPLETE, captureSaved);
      service.addEventListener(IOErrorEvent.IO_ERROR, fail);
      service.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fail);
      try
      {
        service.load(serviceGateway);
      }
      catch(err:Error) {
        trace(err);
        this.reset();
      }
      this.saving();
      
      //trace("saving: " + serviceGateway.data);
    }
    
    private function captureSaved(e:Event):void
    {
      trace("captureSaved");
      if(ExternalInterface.available) ExternalInterface.call("a11351932542_captureSaved");
      this.reset();
    }
    
    private function fail(e:Event):void
    {
      trace("zomg fail: ",e);
      this.reset();
    }
    
    private function saving():void
    {
      try
      {
        this.removeChild(_save);
        this.removeChild(_redo);
      }
      catch(e:Error) { }
    }
    
    private function reset():void
    {
      try
      {
        this.removeChild(_save);
        this.removeChild(_redo);
      }
      catch(e:Error) { }
      _take.visible = true;
      _temp_capture.visible = false;
      video_container.addEventListener(MouseEvent.CLICK, startCapture);
      video_container.useHandCursor = video_container.buttonMode = true;
    }
    
    private function convertToPNG(b:BitmapData):ByteArray
    {
      return PNGEnc.encode(b);
    }
    
    private function activityHandler(event:ActivityEvent):void
    {
      //trace("activityHandler: " + event);
    }
    
    private function drawOverlay():void
    {
      _overlay.graphics.clear();
      _overlay.graphics.lineStyle(0,0xffffff);
      _overlay.graphics.moveTo(0,_video.height/2);
      _overlay.graphics.lineTo(-_video.width, _video.height/2);
      _overlay.graphics.moveTo(-_video.width/2, 0);
      _overlay.graphics.lineTo(-_video.width/2,_video.height);
    }
    
    private function resize(e:Event=null):void
    {
      var stage_ratio:Number = stage.stageWidth/stage.stageHeight;
      var video_ratio:Number = Math.abs(video_container.width/video_container.height);
      trace(stage_ratio,video_ratio,video_container.width,video_container.height);
      
      if(stage_ratio > video_ratio)
      {
        video_container.width = stage.stageHeight*video_ratio;
        video_container.height = stage.stageHeight;
      }
      else
      {
        video_container.width = stage.stageWidth;
        video_container.height = stage.stageWidth/video_ratio;
      }
      video_container.y = (stage.stageHeight - video_container.height)/2;
      video_container.x = (stage.stageWidth) -((stage.stageWidth - video_container.width)/2);
      _take.x = (stage.stageWidth - _take.width)/2;
      _take.y = (stage.stageHeight) - _take.height - this.DEFAULT_MARGIN;
      _save.x = (stage.stageWidth/2) - _save.width - this.DEFAULT_MARGIN;
      _redo.x = (stage.stageWidth/2) + this.DEFAULT_MARGIN;
      _save.y = this.DEFAULT_MARGIN;
      _redo.y = this.DEFAULT_MARGIN;
    }
  }
}
