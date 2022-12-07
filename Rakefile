require 'rake'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
end

# Copied over from Hanami codebase.
# We don't want to include 'hanami/rake_tasks' because we don't want to include db:migrate.
desc 'Load the full project'
task :environment do
  require 'hanami/components'
  require 'hanami/environment'
  Hanami::Environment.new.require_project_environment
  Hanami::Components.resolve('all')
end
