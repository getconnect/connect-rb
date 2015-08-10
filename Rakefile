require 'bundler/gem_tasks'
require 'rake/testtask'

namespace :test do
  desc 'Run the tests'
  Rake::TestTask.new(:spec) do |t|
    t.libs = ['lib', 'spec']
    t.warning = false
    t.verbose = true
    t.test_files = FileList['spec/connect_client/security/*_spec.rb', 'spec/connect_client/http/*_spec.rb', 'spec/connect_client/*_spec.rb', 'spec/*_spec.rb']
  end
  
  desc 'Run the synchrony tests'
  Rake::TestTask.new(:synchrony => :spec) do |t|
    t.libs = ['lib', 'spec']
    t.warning = false
    t.verbose = true
    t.test_files = FileList['spec/connect_client/http/synchrony/*_spec.rb']
  end
end

task :default => "test:synchrony"