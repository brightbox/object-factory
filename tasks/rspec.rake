# Fails gracefully if rspec gem isn't installed
begin
  require "rubygems"
  require "spec"
  require "spec/rake/spectask"

  desc "Run the specs under spec/*"
  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = ["--options", "spec/spec.opts"]
    t.spec_files = FileList["spec/*_spec.rb"]
  end
rescue LoadError
  rescue LoadError
    puts <<-EOS
  To use rspec for testing you must install rspec gem:
    [sudo] gem install rspec
  EOS
end
