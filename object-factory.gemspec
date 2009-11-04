# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{object-factory}
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brightbox Systems Ltd"]
  s.date = %q{2009-11-04}
  s.description = %q{A simple object factory to help you build valid objects in your tests}
  s.email = %q{hello@brightbox.co.uk}
  s.extra_rdoc_files = ["CHANGELOG", "README.rdoc", "lib/object_factory.rb", "tasks/rspec.rake"]
  s.files = ["CHANGELOG", "Manifest", "README.rdoc", "Rakefile", "github.rb", "init.rb", "lib/object_factory.rb", "object-factory.gemspec", "spec/object_spec.rb", "spec/spec.opts", "tasks/rspec.rake"]
  s.homepage = %q{http://github.com/brightbox/object-factory}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Object-factory", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{object-factory}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{A simple object factory to help you build valid objects in your tests}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<brightbox-rujitsu>, [">= 0"])
    else
      s.add_dependency(%q<brightbox-rujitsu>, [">= 0"])
    end
  else
    s.add_dependency(%q<brightbox-rujitsu>, [">= 0"])
  end
end
