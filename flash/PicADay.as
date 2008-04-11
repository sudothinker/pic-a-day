package
{
  import flash.display.Sprite;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.display.BitmapData;
  import flash.events.*;
  import flash.media.Camera;
  import flash.media.Video;
  import flash.utils.Timer;
  import flash.utils.ByteArray;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import com.dynamicflash.util.Base64;
  
  public class PicADay extends Sprite
  {
    private var video_container:Sprite;
    private var _video:Video;
    private var _save:Sprite;
    private var _redo:Sprite;
    private var _overlay:Sprite;
    private var _temp_capture:Sprite;
    
    private var _bitmap_container:BitmapData;
    
    private const DEFAULT_CAPTURE_HANGTIME:Number = 1000;
    private const DEFAULT_CAMERA_WIDTH:int = 480;
    private const DEFAULT_CAMERA_HEIGHT:int = 360;
    private const DEFAULT_CAMERA_FPS:Number = 25;
    private const DEFAULT_MARGIN:Number = 8;
    
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
      this.drawUI();
      this.addChild(video_container);
      var camera:Camera = Camera.getCamera("2");
      
      if (camera != null)
      {
        camera.addEventListener(ActivityEvent.ACTIVITY, activityHandler);
        camera.setMode(this.DEFAULT_CAMERA_WIDTH, this.DEFAULT_CAMERA_HEIGHT, this.DEFAULT_CAMERA_FPS);
        _video = new Video(this.DEFAULT_CAMERA_WIDTH, this.DEFAULT_CAMERA_HEIGHT);
        _video.smoothing = true;
        _video.attachCamera(camera);
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
      video_container.addEventListener(MouseEvent.CLICK, capture);
      video_container.useHandCursor = video_container.buttonMode = true;
      this.resize();
    }

    private function drawUI():void
    {
      _save = new Sprite();
      _redo = new Sprite();

      _save.graphics.lineStyle(1,0x888888, 0.5, true);
      _save.graphics.beginFill(0x000000, 0.5);
      _save.graphics.drawRoundRect(0,0,64,64,8,8);
      _save.graphics.endFill();
      _save.graphics.lineStyle(8,0x22aa22);
      _save.graphics.moveTo(16,16);
      _save.graphics.drawCircle(32,32,16);
      _save.addEventListener(MouseEvent.CLICK, saveCapture);
      _save.useHandCursor = _save.buttonMode = true;
      
      _redo.graphics.lineStyle(1,0x888888, 0.5, true);
      _redo.graphics.beginFill(0x000000, 0.5);
      _redo.graphics.drawRoundRect(0,0,64,64,8,8);
      _redo.graphics.endFill();
      _redo.graphics.lineStyle(8,0xcc2211);
      _redo.graphics.moveTo(16,16);
      _redo.graphics.lineTo(48,48);
      _redo.graphics.moveTo(16,48);
      _redo.graphics.lineTo(48,16);
      _redo.addEventListener(MouseEvent.CLICK, clearCapture);
      _redo.useHandCursor = _redo.buttonMode = true;
      
    }
    
    private function capture(e:Event):void
    {
      video_container.removeEventListener(MouseEvent.CLICK, capture);
      video_container.useHandCursor = video_container.buttonMode = false;
      _bitmap_container = new BitmapData(_video.width, _video.height);
      _bitmap_container.draw(_video);
      _temp_capture.graphics.clear();
      _temp_capture.graphics.beginBitmapFill(_bitmap_container,null,false,true);
      _temp_capture.graphics.drawRect(0,0,_video.width, _video.height);
      _temp_capture.graphics.endFill();
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
            
      var fb_user_id:String = root.loaderInfo.parameters['fb_user_id']
      var user_hash:String = root.loaderInfo.parameters['user_hash']
            
      var serviceGateway:URLRequest = new URLRequest('http://0.0.0.0:3000/capture');
      serviceGateway.method = "POST";
      serviceGateway.data = fb_user_id + "|" + user_hash + "|" + Base64.encodeByteArray(png);
      service.load(serviceGateway);

      this.reset();
      
      trace("saving: " + serviceGateway.data);
    }
    
    private function reset():void
    {
      try
      {
        this.removeChild(_save);
        this.removeChild(_redo);
      }
      catch(e:Error) { }
      _temp_capture.visible = false;
      video_container.addEventListener(MouseEvent.CLICK, capture);
      video_container.useHandCursor = video_container.buttonMode = true;
    }
    
    private function convertToPNG(b:BitmapData):ByteArray
    {
      return PNGEnc.encode(b);
    }
    
    private function activityHandler(event:ActivityEvent):void
    {
      trace("activityHandler: " + event);
    }
    
    private function drawOverlay():void
    {
      _overlay.graphics.clear();
      _overlay.graphics.lineStyle(0,0xffffff);
      _overlay.graphics.moveTo(0,_video.height/2);
      _overlay.graphics.lineTo(_video.width, _video.height/2);
      _overlay.graphics.moveTo(_video.width/2, 0);
      _overlay.graphics.lineTo(_video.width/2,_video.height);
    }
    
    private function resize(e:Event=null):void
    {
      var stage_ratio:Number = stage.stageWidth/stage.stageHeight;
      var video_ratio:Number = video_container.width/video_container.height;
      
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
      video_container.x = (stage.stageWidth - video_container.width)/2;
      video_container.y = (stage.stageHeight - video_container.height)/2;
      _save.x = video_container.x + (video_container.width/2) - (_save.width) - this.DEFAULT_MARGIN/2;
      _redo.x = video_container.x + (video_container.width/2) + this.DEFAULT_MARGIN/2;
      _save.y = this.DEFAULT_MARGIN;
      _redo.y = this.DEFAULT_MARGIN;
    }
  }
}
