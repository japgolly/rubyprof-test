require 'rubygems'
require 'bundler'
Bundler.require :default

#use Rack::ShowExceptions

require 'rack'
load './profile.rb'
use ENV['hack'] ? SingleProfiler : MultiProfiler

class MyApp < Sinatra::Base
  # Create some dummy code to profile
  def target_code(o=1) o= asd(o) while o<30000; omg o end
  def asd(o) omg o; o.to_f * 1.00001 end
  def omg(o) o.to_s end

  # Access it via http://127.0.0.1:9292/test.txt
  get '/test.txt' do
    target_code().to_s
  end
end

run MyApp.new
