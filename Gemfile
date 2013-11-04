source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'tripod', :git => "https://github.com/Swirrl/tripod.git", :branch => 'links'
#gem 'tripod', :path => '../tripod'
gem 'roo'
gem 'tire'

gem 'rdf', '1.0.8'

#gem 'publish_my_data', '1.0.3'
gem 'publish_my_data', :git => "https://github.com/Swirrl/publish_my_data.git", :branch => 'master'
#uncomment to use local pmd (and comment out line above)
#gem 'publish_my_data', :path => '/Users/edwardf/Documents/code/publish_my_data'

gem "sentry-raven", :git => "https://github.com/getsentry/raven-ruby.git", :branch => 'ead49c'

group :assets do
  #gem 'therubyracer', platforms: :ruby
  #gem 'uglifier'
  gem 'yui-compressor' #note:requires java
end

group :development, :test do
  gem "capistrano"
  gem 'rspec-rails', '~> 2.0'
end