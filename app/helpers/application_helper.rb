# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def swf_object_js(swf, id, width, height, flash_version, background_color, params = {}, vars = {})
    output = "var so = new SWFObject('#{swf}', '#{id}_swf', '#{width}', '#{height}', '#{flash_version}', '#{background_color}');"
    params.each  {|key, value| output << "so.addParam('#{key}', '#{value}');"}
    vars.each    {|key, value| output << "so.addVariable('#{key}', '#{value}');"}
    output << "var isIE  = (navigator.appVersion.indexOf('MSIE') != -1) ? true : false;"
    output << "var MMPlayerType = (isIE == true) ? 'ActiveX' : 'PlugIn';"
    output << "var MMredirectURL = window.location;"
    output << "var MMdoctitle = document.title;"
    output << "so.addVariable('MMPlayerType', MMPlayerType);"
    output << "so.addVariable('MMredirectURL', MMredirectURL);"
    output << "so.addVariable('MMdoctitle', MMdoctitle);"
    output << "so.write('#{id}');"
  end
  
  def webcam_capture_js(user_id, hash)
    swf_object_js("/flash/PicADay.swf", 'webcam_capture', '480', '421', '7', '#000000', 
                  {:allowScriptAccess => "always", :wmode => "window"},
                  {:fb_user_id => user_id, :user_hash => hash})
  end
end
