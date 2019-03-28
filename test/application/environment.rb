require_relative 'set_rack_env_and_load_gems'
require_relative 'redis_and_sidekiq'
require_relative 'app_logger'

AppLogger.log_level = ENV['LOG_LEVEL'].try(:to_sym) || :error
require_relative 'info_sig'