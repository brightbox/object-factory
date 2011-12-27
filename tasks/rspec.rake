# Fails gracefully if rspec gem isn't installed
begin
  require "rspec"
  require "rspec/core/rake_task"

  desc "Run the specs under spec/*"
  RSpec::Core::RakeTask.new
rescue LoadError
    puts <<-EOS
  To use rspec for testing you must install rspec gem:
    [sudo] gem install rspec
  EOS
end
