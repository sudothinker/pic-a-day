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
  
  public class PicADay extends Sprite
  {
    private var video_container:Sprite;
    private var _video:Video;
    private var _overlay:Sprite;
    private var _temp_capture:Sprite;
    
    private var _capture_timer:Timer;
    
    private const DEFAULT_CAPTURE_HANGTIME:Number = 1000;
    
    private const DEFAULT_CAMERA_WIDTH:int = 480;
    private const DEFAULT_CAMERA_HEIGHT:int = 360;
    private const DEFAULT_CAMERA_FPS:Number = 25;
    
    public function PicADay()
    {
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;
      
      video_container = new Sprite();
      _overlay = new Sprite();
      _temp_capture = new Sprite();
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
      this.addEventListener(MouseEvent.CLICK, capture);
      this.resize();
    }
    
    private function capture(e:Event):void
    {
      if(_capture_timer) _capture_timer.stop();
      _capture_timer = new Timer(this.DEFAULT_CAPTURE_HANGTIME, 1);
      _capture_timer.addEventListener(TimerEvent.TIMER, this.clearTempCapture)
      var b:BitmapData = new BitmapData(_video.width, _video.height);
      b.draw(_video);
      _temp_capture.graphics.clear();
      _temp_capture.graphics.beginBitmapFill(b,null,false,true);
      _temp_capture.graphics.drawRect(0,0,_video.width, _video.height);
      _temp_capture.graphics.endFill();
      _temp_capture.visible = true;
      this.saveCapture(b);
      _capture_timer.start();
    }
    
    private function clearTempCapture(e:Event):void
    {
      this.removeEventListener(TimerEvent.TIMER, clearTempCapture)
      _temp_capture.visible = false;
    }
    
    private function saveCapture(b:BitmapData):void
    {
      var png:ByteArray = convertToPNG(b);
      png.position = 0;
      var service:URLLoader = new URLLoader();
      service.dataFormat = "binary";
            
      var serviceGateway:URLRequest = new URLRequest('http://0.0.0.0:3000/capture');
      serviceGateway.method = "POST";
      serviceGateway.data = png;      
      service.load(serviceGateway);
      trace("saving...");
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
      //_overlay.graphics.moveTo(0,0);
      //_overlay.graphics.lineTo(_video.width, _video.height);
      //_overlay.graphics.moveTo(_video.width, 0);
      //_overlay.graphics.lineTo(0,_video.height);
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
    }
  }
}