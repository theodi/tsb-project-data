source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'tripod', :git => "https://github.com/Swirrl/tripod.git", :branch => 'd76b33' #lock to the legacy version of tripod
#gem 'tripod', :path => '../tripod'


gem 'rdf', '1.0.8'
gem 'rdf-json', '1.0.0'
gem 'rdf-rdfxml', '1.0.2'
gem 'rdf-turtle', '1.0.9'

#gem 'publish_my_data', '1.0.4' # this is the last version of pmd before we merged legacy in.

gem 'publish_my_data', :git => "https://github.com/Swirrl/publish_my_data.git", :branch => '4eeea' # this is what the live version of the tsb app is running
#uncomment to use local pmd (and comment out line above)
#gem 'publish_my_data', :path => '/Users/edwardf/Documents/code/publish_my_data'

gem "sentry-raven", :git => "https://github.com/getsentry/raven-ruby.git", :branch => 'ead49c'

# lock to some old versions of gems
gem 'sass-rails', '3.2.6'
gem 'sass', '3.2.12'
gem 'tire', '0.6.0'
gem 'kaminari', '0.14.1'
gem 'roo', '1.12.2'

group :assets do
  #gem 'therubyracer', platforms: :ruby
  #gem 'uglifier'
  gem 'yui-compressor' #note:requires java
end

group :development, :test do
  gem "capistrano"
  gem 'rspec-rails', '~> 2.0'
end