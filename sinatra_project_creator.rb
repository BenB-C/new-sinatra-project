#!/usr/bin/env ruby

require 'fileutils'

# undercore method modified from https://stackoverflow.com/questions/1509915/converting-camel-case-to-underscore-case-in-ruby
def to_underscore(string)
   string.gsub(/(.)([A-Z])/,'\1_\2').downcase
end

print 'Enter project name: '
project_name = gets.chomp
project_path = project_name.gsub(' ', '-')
print 'Enter classes: '
class_names = gets.chomp.split(/ |, /).select { |classname| classname != "" && classname != " " }

# create project folder and subfolders in parent of current directory
FileUtils.cd "../"
FileUtils.mkdir [
  project_path,
  "#{project_path}/lib",
  "#{project_path}/public",
  "#{project_path}/public/css",
  "#{project_path}/public/images",
  "#{project_path}/spec",
  "#{project_path}/views"
]
FileUtils.cd project_path
# create stylesheet
FileUtils.touch "public/css/styles.css"
# create layout view
FileUtils.touch "views/layout.erb"
File.write("views/layout.erb", %{<!DOCTYPE html>
<html>
  <head>
    <title>#{project_name}</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="/css/styles.css">
  </head>
  <body>
    <div class="container">
      <%= yield %>
    </div>
  </body>
</html>
})
# create app file
FileUtils.touch "app.rb"
# create heroku config file
FileUtils.touch "config.ru"
File.write("config.ru", "require ('./app')\nrun Sinatra::Application")
# create Gemfile
FileUtils.touch "Gemfile"
File.write("Gemfile", %{source 'https://rubygems.org'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'rspec'
gem 'pry'
gem 'pivotal_git_scripts'
gem 'capybara'
gem 'pg'
})
# create integration spec file
FileUtils.touch "integration_spec.rb"
File.write("integration_spec.rb", %{require 'capybara/rspec'
require './app'
Capybara.app = Sinatra::Application
set(:show_exceptions, false)
})
# create spec helper file
spec_helper_path = "spec/spec_helper.rb"
FileUtils.touch spec_helper_path
# create class and spec files
class_names.each do |class_name|
  # create lib file
  lib_filename = "#{to_underscore(class_name)}.rb"
  lib_filepath = "lib/#{lib_filename}"
  FileUtils.touch lib_filepath
  File.write(lib_filepath, "class #{class_name}\n\nend")
  # create spec file
  spec_filepath = "spec/#{to_underscore(class_name)}_spec.rb"
  FileUtils.touch spec_filepath
  File.write(spec_filepath, %{require 'spec_helper.rb'

describe('##{class_name}') do

end
})
  File.write(spec_helper_path, "require '#{lib_filename.sub('.rb','')}'\n", mode: "a")
  # add require to app file
  File.write("app.rb", "require './lib/#{lib_filename.sub('.rb','')}'\n", mode: "a")
end
# add more requires to spec helper file
database_name = project_name.gsub(' ','_').downcase
File.write(spec_helper_path, %{require 'rspec'
require 'pg'
require 'pry'

DB = PG.connect({:dbname => '#{database_name}_test'})

RSpec.configure do |config|
  config.after(:each) do

  end
end
}, mode: "a")
# add requires to app filw
File.write("app.rb", %{require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'
also_reload 'lib/**/*.rb'

get ('/') do

end
}, mode: "a")
# run bundle install and git init
system "cd ../#{project_path}"
system "bundle install"
system "git init"
system "atom ."
