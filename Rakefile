require 'rake/testtask'

desc 'Run all tests'
task :test do
  $LOAD_PATH.unshift(File.expand_path('test'))
  require 'test/unit'
  Dir['test/*/**/test_*.rb'].each {|test| require "./#{test}" }
end

desc 'Generate YARD Documentation'
task :doc do
  sh "mv README.md TEMPME"
  sh "rm -rf doc"
  sh "yardoc"
  sh "mv TEMPME README.md"
end

namespace :gem do

  desc 'Build and install the ram gem'
  task :install do
    sh "gem build ram.gemspec"
    sh "gem install #{Dir['*.gem'].join(' ')} --local"
  end

  desc 'Uninstall the ram gem'
  task :uninstall do
    sh "gem uninstall -x ram"
  end

end

task :default => :test
