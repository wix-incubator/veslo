source "http://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.

gem 'mixlib-cli'
gem 'rest-client', '~> 1.8.0' # This change was made via Snyk to fix a vulnerability
gem 'json'

if defined?(JRUBY_VERSION)
  gem 'jruby-openssl'
end

group :development do
  gem "rdoc"
  gem "fakeweb"
  gem "rspec", "~> 2.7.0"
  gem "jeweler", "~> 1.6.4"
end
