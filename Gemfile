# frozen_string_literal: true

source 'https://rubygems.org'

ruby RUBY_VERSION

gem 'rake'

group :development, :test do
  gem 'pry'
  gem 'activesupport', require: false
  # gem 'sidekiq-scheduler'
  gem 'sidekiq'
  gem 'sequel'
  gem 'ramda-ruby'
  gem 'redlock'
end

group :test do
  gem 'minitest'
  gem 'minitest-parallel_fork', require: false
  gem 'rack-test'
  # gem "webmock"
  # gem 'vcr'
  gem 'm', '~> 1.5.0'
  # gem 'timecop'
end

gemspec
