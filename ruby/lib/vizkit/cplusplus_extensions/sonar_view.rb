#prepares the c++ qt widget for the use in ruby with widget_grid

Vizkit::UiLoader::extend_cplusplus_widget_class "SonarView" do
  def default_options()
      options = Hash.new
      options[:time_overlay] = true
      return options
  end

  def save(path)
	saveImage2(path)
  end

  def save_frame(frame,path)
        saveImage3(frame.frame_mode.to_s,frame.pixel_size,frame.size.width,frame.size.height,frame.image.to_byte_array[8..-1],path)
  end

  #diplay is called each time new data are available on the orocos output port
  #this functions translates the orocos data struct to the widget specific format
  def display(sonar_scan,port_name)
    #check if type is frame_pair
    if !defined? @init
      @options ||= default_options
      openGL true
      @time_overlay_object = addText(-150,-5,0,"time")
      @time_overlay_object.setColor(Qt::Color.new(255,255,0))
      @time_overlay_object.setPosFactor(1,1);
      @time_overlay_object.setBackgroundColor(Qt::Color.new(0,0,0,40))
      @init = true
    end

    if @options[:time_overlay] == true
      if sonar_scan.class.name == "/base/samples/SonarScan"
        if sonar_scan.time.instance_of?(Time)
	  time = sonar_scan.time
        elsif sonar_scan.class.name == "/base/samples/SonarScan"
	  if sonar_scan.stamp.instance_of?(Time)
	    time = sonar_scan.stamp
	end
    else
      time = Time.at(frame.time.seconds,frame.time.microseconds)
    end
      @time_overlay_object.setText(time.strftime("%b %d %Y %H:%M:%S"))
    end
    if sonar_scan.class.name == "/base/samples/SonarScan"
      setSonarScan(sonar_scan.scanData.to_byte_array[8..-1],sonar_scan.scanData.size,sonar_scan.angle,sonar_scan.time_beetween_bins,false)
    elsif sonar_scan.class.name == "/sonar_data/SonarScan"
      setSonarScan(sonar_scan.scanData.to_byte_array[8..-1],sonar_scan.scanData.size,sonar_scan.bearing,sonar_scan.adInterval,true)
    else
      STDERR.puts "Cannot Handle Data of type: #{sonar_scan.class.name}, please check vizkit/ruby/lib/vizkit/cplusplus_extensions/sonar_view.rb" 
    end
      update2
    end
  end
end

Vizkit::UiLoader.register_widget_for("SonarView","/sensorData/Sonar",:display)
Vizkit::UiLoader.register_widget_for("SonarView","/base/samples/SonarScan",:display)