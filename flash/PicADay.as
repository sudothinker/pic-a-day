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
  import flash.net.navigateToURL;
  
  [SWF(backgroundColor="#ffffff", frameRate="30")]
  
  public class PicADay extends Sprite
  {
    private var fb_user_id:String;
    private var user_hash:String;
    private var fb_page_id:String;
    private var fb_sig_is_admin:String;
    private var fb_sig_page_added:String;
    
    private var video_container:Sprite;
    private var _video:Video;
    private var _camera:Camera;
    private var _save:Sprite;
    private var _redo:Sprite;
    private var _take:Sprite;
    private var _countdown_display:TextField;
    private var _overlay:Sprite;
    private var _spinner:Spinner;
    private var _temp_capture:Sprite;
    private var _camera_index:int;
    
    private var _camera_finder:Timer;
    private var _capture_timer:Timer;
        
    private var _bitmap_container:BitmapData;
    
    private const HANGTIME:Number = 1000;
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
      //this.resize();
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
      _spinner = new Spinner();
      _spinner.visible = true;
      
      var display_format:TextFormat = new TextFormat("_sans", 24, 0xffffff);
      display_format.align = "center";
      _countdown_display.defaultTextFormat = display_format;
      _countdown_display.autoSize = "center";
      _countdown_display.wordWrap = true;
      _countdown_display.selectable = false;
      _video = new Video(this.DEFAULT_CAMERA_WIDTH, this.DEFAULT_CAMERA_HEIGHT);
      
      this.addChild(video_container);
      video_container.addChild(_video);
      video_container.addChild(_overlay);
      video_container.addChild(_temp_capture);
      video_container.addChild(_spinner);
      
      //_camera = Camera.getCamera();
      //_camera.setMotionLevel(10,100);
      //_camera.setMode(32,24,60,false);
      //_camera.addEventListener(ActivityEvent.ACTIVITY, cameraFound);
      _video.smoothing = true;
      //_video.attachCamera(_camera);
      _video.scaleX = -1;
      _spinner.x = -(_video.width/2);
      _spinner.y = (_video.height-_spinner.height);

      _camera_index = 0;
      _camera_finder = new Timer(1000,0);
      _camera_finder.addEventListener(TimerEvent.TIMER,findCamera);
      _camera_finder.start();
      
      
    }
    
    private function findCamera(e:Event=null):void
    {
      _video.clear();
      _camera_index = (_camera_index+1)%Camera.names.length;
      _camera = Camera.getCamera(String(_camera_index));
      _camera.setMotionLevel(10,80);
      _video.attachCamera(_camera);
      _camera.addEventListener(ActivityEvent.ACTIVITY, cameraFound);
      trace("trying " + _camera.name);
    }
    
    private function cameraFound(e:Event=null):void
    {
      trace("camera found: " + _camera.name + ", " + _camera.activityLevel);
      _camera.setMode(this.DEFAULT_CAMERA_WIDTH, this.DEFAULT_CAMERA_HEIGHT, this.DEFAULT_CAMERA_FPS);
      _camera_finder.removeEventListener(TimerEvent.TIMER, findCamera);
      _camera.removeEventListener(ActivityEvent.ACTIVITY, cameraFound);
      _camera_finder.stop();
      _spinner.visible = false;
      this.drawUI();
      this.drawOverlay();
      this.addChild(_take);
      this.resize();
      stage.addEventListener(Event.RESIZE, resize);
      _take.addEventListener(MouseEvent.CLICK, startCapture);
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
      _countdown_display.scaleX = _countdown_display.scaleY *= (stage.stageHeight/_countdown_display.height)/3.5;
      _countdown_display.x = (stage.stageWidth-_countdown_display.width)/2;
      _countdown_display.y = (stage.stageHeight-_countdown_display.height);
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
      _spinner.visible = true;

      var png:ByteArray = convertToPNG(_bitmap_container);
      png.position = 0;
      var service:URLLoader = new URLLoader();
      service.dataFormat = "binary";
            
      this.fb_user_id = root.loaderInfo.parameters['fb_user_id']
      this.user_hash = root.loaderInfo.parameters['user_hash']
      
      this.fb_page_id = root.loaderInfo.parameters['fb_page_id']
      this.fb_sig_is_admin = root.loaderInfo.parameters['fb_sig_is_admin']
      this.fb_sig_page_added = root.loaderInfo.parameters['fb_sig_page_added']
            
      var serviceGateway:URLRequest = new URLRequest('http://stage.pseudothinker.com/capture');
      serviceGateway.method = "POST";
      serviceGateway.data = this.fb_user_id + "|" + this.user_hash + "|" + this.fb_page_id + "|" + this.fb_sig_is_admin + "|" + this.fb_sig_page_added + "|" + Base64.encodeByteArray(png);
      //service.addEventListener(Event.COMPLETE, captureSaved);
      service.addEventListener(IOErrorEvent.IO_ERROR, fail);
      service.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fail);
      try
      {
        service.load(serviceGateway);
      }
      catch(err:Error) {
        trace(err);
        //this.reset();
      }
      this.saving();
      
      //trace("saving: " + serviceGateway.data);
    }
    
    private function captureSaved(e:Event):void
    {
      //trace("captureSaved");
      //var refresh_timer:Timer = new Timer(this.HANGTIME,1);
      //refresh_timer.addEventListener(TimerEvent.TIMER, refresh);
      //refresh_timer.start();
      //if(ExternalInterface.available) ExternalInterface.call("captureSaved",this.fb_user_id,this.user_hash);
      //this.reset();
    }
    
    /*
    private function refresh(e:Event):void
    {
      flash.net.navigateToURL(new URLRequest(root.loaderInfo.url.substring(0,root.loaderInfo.url.lastIndexOf('/'))), "_self");
    }
    */
    
    private function fail(e:Event):void
    {
      //flash.net.navigateToURL(new URLRequest(root.loaderInfo.url.substring(0,root.loaderInfo.url.lastIndexOf('/'))), "_self");
      trace("zomg fail: ",e);
      //this.reset();
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
      _spinner.visible = false;
      _temp_capture.visible = false;
      _take.addEventListener(MouseEvent.CLICK, startCapture);
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
      //trace(stage_ratio,video_ratio,video_container.width,video_container.height);
      
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
      try
      {
        video_container.y = (stage.stageHeight - video_container.height)/2;
        video_container.x = (stage.stageWidth) -((stage.stageWidth - video_container.width)/2);
        _take.x = (stage.stageWidth - _take.width)/2;
        _take.y = (stage.stageHeight) - _take.height - this.DEFAULT_MARGIN;
        _spinner.x = -(_video.width/2);
        _spinner.y = (_video.height-_spinner.height);
        _save.x = (stage.stageWidth/2) - _save.width - this.DEFAULT_MARGIN;
        _redo.x = (stage.stageWidth/2) + this.DEFAULT_MARGIN;
        _save.y = this.DEFAULT_MARGIN;
        _redo.y = this.DEFAULT_MARGIN;
      }
      catch(e:Error) { }
    }
  }

}

import flash.display.Sprite;
import flash.events.Event;

class Spinner extends flash.display.Sprite
{
  
  public function Spinner()
  {
    super();
    for(var i:int=0; i<12; i++)
    {
      var tab:Sprite = new Sprite;
      tab.graphics.beginFill(0xaaaaaa,(1/12)*i);
      tab.graphics.drawRoundRect(-1,-10,2,6,2,2);
      tab.graphics.endFill();
      tab.rotation = (360/12)*i;
      this.addChild(tab);
    }
    this.addEventListener(Event.ENTER_FRAME, spin);
    this.visible = false;
  }
  
  private function spin(e:Event):void
  {
    this.rotation = (this.rotation+(360/12))%360;
  }
}

