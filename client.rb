#!/usr/bin/env ruby

require 'rubygems'
require 'httparty'
HTTParty.get 'http://127.0.0.1:9292/test.txt'
HTTParty.get 'http://127.0.0.1:9292/test.txt'

puts "Done. Now go and ctrl-c the server."
