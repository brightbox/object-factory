# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  load 'tasks/setup.rb'
end

ensure_in_path 'lib'
require 'object-factory'

task :default => 'spec:run'

PROJ.name = 'object-factory'
PROJ.authors = 'Rahoul Baruah for Brightbox Systems Ltd'
PROJ.email = 'support@brightbox.co.uk'
PROJ.url = 'http://www.brightbox.co.uk/'
PROJ.version = ObjectFactory::0.1
PROJ.rubyforge.name = 'object-factory'

PROJ.spec.opts << '--color'

# EOF
