require 'rake/testtask'
require 'bundler/gem_tasks'
require 'find'

desc 'Say hello'
task :hello do
  puts "Hello there. This is the 'hello' task."
  puts
end

desc 'Say goodbye'
task :goodbye do
  puts
  puts "Goodbye!"
end

desc 'List all non-hidden files not in coverage folder'
task :list do
  Find.find('.') do |name|
    next if name =~ %r{/\.|/coverage}
    puts name if File.file?(name)
  end
end

desc 'Greet and run tests'
task :default => [:hello, :test, :goodbye]

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib' # unnecessary?
  t.test_files = FileList['test/**/*_test.rb']
  # p t.class
  # p t.inspect
  # p t.libs        # ["lib", "test", "lib"]      # 2 'lib's ?
end
