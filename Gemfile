# frozen_string_literal: true

source 'https://rubygems.org'

ruby RUBY_VERSION

gem 'rake'


group :development, :test do
  gem 'pry'
  gem 'activesupport', '~> 6.0.3', '>= 6.0.3.7'
  # gem 'sidekiq-scheduler'
  gem 'sidekiq', '~> 6'
  gem 'sequel'
  gem 'ramda-ruby'
  gem 'redlock'

  gem 'concurrent-ruby'
end

group :test do
  gem 'minitest'
  gem 'minitest-parallel_fork', require: false
  gem 'rack-test'

  gem 'concurrent-ruby'

  # gem "webmock"
  # gem 'vcr'
  gem 'm', '~> 1.5.0'
  gem 'timecop'
end

gemspec
