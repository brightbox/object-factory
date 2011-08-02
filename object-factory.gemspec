# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "object_factory/version"

Gem::Specification.new do |s|
  s.name        = "object-factory"
  s.version     = Object::Factory::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brightbox Systems Ltd"]
  s.email       = %q{hello@brightbox.co.uk}
  s.homepage    = %q{http://github.com/brightbox/object-factory}
  s.summary     = %q{A simple object factory to help you build valid objects in your tests}
  s.description = %q{A simple object factory to help you build valid objects in your tests}

  s.required_ruby_version = '>= 1.8.7'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Object-factory", "--main", "README.rdoc"]

  s.add_dependency "rujitsu"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "< 2.0"
  s.add_development_dependency 'activerecord', '> 2.0'
  s.add_development_dependency 'sqlite3'
end
