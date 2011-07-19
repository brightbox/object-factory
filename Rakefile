require "rubygems"
require 'bundler'
Bundler::GemHelper.install_tasks

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each do | rake_file | 
  load rake_file
end
