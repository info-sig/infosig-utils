require_relative 'set_rack_env_and_load_gems'
require_relative 'redis_and_sidekiq'

AppLogger.log_level = ENV['LOG_LEVEL'].try(:to_sym) || :error
require_relative 'info_sig'