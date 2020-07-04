#!/usr/bin/ruby
require 'yaml'
require_relative 'src/builder'

puts "please specify a spec to build" and exit if ARGV.empty?

Builder.new(ARGV[0]).generate

