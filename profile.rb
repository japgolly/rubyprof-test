require 'ruby-prof'

class SingleProfiler

  def initialize(app, options = {})
    # YOU CANT STOP THE HACKING!!!
    measure= case @name= ENV['hack']
             when 'wall-single' then RubyProf::WALL_TIME
             when 'process-single' then RubyProf::PROCESS_TIME
             when 'cpu-single' then RubyProf::CPU_TIME
             else raise "hacking fail: #{@name.inspect}"
             end
    puts "Using #@name"

    @app= app
    @profile= RubyProf::Profile.new(measure, [])
    #@profile= RubyProf::Profile.new(RubyProf::PROCESS_TIME, [])
    #@profile.start
    #@profile.pause
    at_exit { stop_profiling }
  end

  def call(env)
    #@profile.resume {
    #  @app.call(env)
    #}
    @profile.resume
    begin
      @app.call(env)
    ensure
      @profile.pause
    end
  end

  protected

  def stop_profiling
    require 'fileutils'
    profile_dir= "output-rack"
    puts "Writing #@name profile results to #{profile_dir}"
    FileUtils.mkdir_p profile_dir

    @profile.resume
    result= @profile.stop
    printer = RubyProf::MultiPrinter.new(result)
    printer.print(path: profile_dir, profile: @name)
  end
end


class MultiProfiler
  def initialize(app, options = {})
    puts "Using multi"
    @app= app
    @p_wall= RubyProf::Profile.new(RubyProf::WALL_TIME, [])
    @p_proc= RubyProf::Profile.new(RubyProf::PROCESS_TIME, [])
    @p_cpu= RubyProf::Profile.new(RubyProf::CPU_TIME, [])
    #prof :start
    #prof :pause
    at_exit { stop_profiling }
  end

  def call(env)
    prof :resume
    begin
      @app.call(env)
    ensure
      prof :pause
    end
  end

  protected

  def prof(method, *args)
    [@p_wall, @p_proc, @p_cpu].each{|p| p.send method, *args}
  end

  def stop_profiling
    require 'fileutils'
    profile_dir= "output-rack"
    puts "Writing profile results to #{profile_dir}"
    FileUtils.mkdir_p profile_dir

    [
      [@p_wall,"wall-multi"],
      [@p_proc,"process-multi"],
      [@p_cpu,"cpu-multi"],
    ].each do |p,name|
      p.resume
      result= p.stop
      printer = RubyProf::MultiPrinter.new(result)
      printer.print(path: profile_dir, profile: name)
    end

  end
end

