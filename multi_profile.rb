#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.require :default

# Create output directory
require 'fileutils'
OUTPUT_DIR= "output-ruby"
FileUtils.mkdir_p OUTPUT_DIR

# Create some dummy code to profile
def target_code(o=1) o= asd(o) while o<30000; omg o end
def asd(o) omg o; o.to_f * 1.00001 end
def omg(o) o.to_s end

# Test method profiles dummy code above and creates output files
def test(type_to_name)
  profiles= []
  profile_to_name= {}
  type_to_name.each do |type,name|
    profiles<< p= RubyProf::Profile.new(type, [])
    profile_to_name[p]= name
  end
  puts "Creating profiles: #{type_to_name.values.sort.join ','}"
  start= Time.now

  # Call dummy code
  profiles.each(&:resume)
  target_code 1
  profiles.each(&:pause)

  # Call dummy code again
  profiles.each(&:resume)
  target_code 5
  profiles.each(&:pause)

  fin= Time.now
  printf "  Time: %.1f sec\n", fin-start

  # Save results
  profile_to_name.each do |p,name|
    p.resume
    result= p.stop
    printer = RubyProf::MultiPrinter.new(result)
    printer.print(path: OUTPUT_DIR, profile: name)
  end
end

# ------------------------------------------------------------------------------
# The testing begins...

# Warmup
print "Warming up.."
5.times { print '.'; target_code 5 }
puts

# Test each kind of profile on its own
test RubyProf::WALL_TIME => 'wall-single'
test RubyProf::PROCESS_TIME => 'process-single'
test RubyProf::CPU_TIME => 'cpu-single'

# Now profile the dummy code once using all 3 profiles
test RubyProf::WALL_TIME => 'wall-multi',
     RubyProf::PROCESS_TIME => 'process-multi',
     RubyProf::CPU_TIME => 'cpu-multi'

# Manually compare the results
puts "Done."
exit 0
