# Why is Sidekiq ALWAYS in development mode, https://github.com/info-sig/InfoSwitch/issues/130
# Make Sidekiq multi-process, https://github.com/info-sig/InfoSwitch/issues/212

# IMPORTANT: do not have anything output to STDOUT in this ruby script or funny things will happen in script/worker
require 'rubygems'
require 'bundler'

APPLICATION_NAME = "__my_app__"

# require 'dotenv'
# Dotenv.load

# Hmf, https://groups.google.com/forum/#!msg/sequel-talk/yQQRL1nYAsA/HOwyn2CbpQcJ
$VERBOSE = false

RACK_ENV = (ENV['RACK_ENV']  || 'development').to_sym

Bundler.require(:default, RACK_ENV)
require 'ramda' # WTF?? Why is this necessary?

if RACK_ENV != :production
  require 'pry'
end

# Make Sidekiq multi-process, https://github.com/info-sig/InfoSwitch/issues/212
require 'sidekiq'
# require 'sidekiq-scheduler'

require 'active_support/cache'
require "logger"
require 'active_support'
require 'active_support/core_ext'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/enumerable'
require 'active_support/concern'
require 'active_support/gzip'

require 'sidekiq/api'

# ARGH, https://github.com/info-sig/InfoSwitch/issues/192
Thread.abort_on_exception = true