#!/usr/bin/env ruby

require 'fileutils'

# undercore method modified from https://stackoverflow.com/questions/1509915/converting-camel-case-to-underscore-case-in-ruby
def to_underscore(string)
   string.gsub(/(.)([A-Z])/,'\1_\2').downcase
end

print 'Project name: '
project_name = gets.chomp.gsub(' ', '_')
print 'Classes: '
class_names = gets.chomp.split(/ |,|, /)
print 'Gems (rspec, pry & pivotal_git_scripts included by default): '
gems = gets.chomp.split(/ |, /) + ['rspec', 'pry', 'pivotal_git_scripts']

# create project folder in parent of current directory
FileUtils.cd "../"
FileUtils.mkdir [project_name, project_name + "/lib", project_name + "/spec"]
FileUtils.cd project_name
# create script file
script_filepath = "#{project_name}_script.rb"
FileUtils.touch script_filepath
File.write(script_filepath, "#!/usr/bin/env ruby\n\n")
class_names.each do |class_name|
  # create lib file
  lib_filename = "#{to_underscore(class_name)}.rb"
  lib_filepath = "lib/" + lib_filename
  FileUtils.touch "lib/#{lib_filename}"
  File.write(lib_filepath, "class #{class_name}\nend")
  # create spec file
  spec_filepath = "spec/#{to_underscore(class_name)}_spec.rb"
  FileUtils.touch spec_filepath
  File.write(spec_filepath, "require 'rspec'\nrequire 'pry'\n")
  File.write(spec_filepath, "require '#{lib_filename.sub('.rb','')}'\n", mode: "a")
  File.write(spec_filepath, %Q(
describe('#{class_name}') do
  it('') do
    expect().to(eq())
  end
end
  ), mode: "a")
  # add require for class to script file
  File.write(script_filepath, "require './lib/#{lib_filename.sub('.rb','')}'\n", mode: "a")
end
# create Gemfile
FileUtils.touch 'Gemfile'
gem_file_text = "source 'https://rubygems.org'\n\n"
gems.each do |gem|
  gem_file_text += "gem '#{gem}'\n"
end
File.write('Gemfile', gem_file_text)
