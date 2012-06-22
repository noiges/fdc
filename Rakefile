require 'rake/testtask'
require 'gem-licenses'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

desc "Launch irb session preloaded with this lib"
task :console do
  sh "irb -rubygems -I lib -r fdc.rb"
end

desc "Launch executable preloaded with this lib and required debug"
task :debug do
  sh "ruby -rubygems -I lib -r debug bin/fdc"
end

desc "Build gem with current .gemspec"
task :build do
  sh "gem build fdc.gemspec"
end

desc "Get licenses of gems"
task :licenses do
  Gem.licenses.each do |license, gems| 
    puts "#{license}"
    gems.sort_by { |gem| gem.name }.each do |gem|
      puts "* #{gem.name} #{gem.version} (#{gem.homepage}) - #{gem.summary}"
    end
  end
end