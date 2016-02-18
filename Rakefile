require 'rubygems'
require 'bundler'
Bundler.setup :default, :test, :development

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: [:rubocop, :spec]

require 'yard'
DOC_FILES = ['lib/**/*.rb', 'README.md']

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = DOC_FILES
end
