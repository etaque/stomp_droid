require 'rake/clean'
require 'rspec/core/rake_task'

CLEAN.concat %w{
    SPECS
}

task :default => :spec

begin
  desc "Run specs"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = ["-f d"]
    t.pattern = 'spec/**/*_spec.rb'
  end
rescue LoadError
    puts '[WARN] rspec not installed - spec tasks disabled'
end
