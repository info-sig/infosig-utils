class AppLogger

  module Helpers
    def log
      AppLogger
    end

    def D string
      log.debug string
    end
  end

  class << self
    delegate :log, :info, :error, :debug, :warn,
      to: :_instance
  end

  cattr_accessor :log_level
  #delegate :log_level, to: 'self.class'

  # !!!! NOT FOR PRODUCTION USE !!!!
  def self.with_log_level tmp_log_level
    old_log_level = self.log_level
    self.log_level = tmp_log_level
    yield
  ensure
    self.log_level = old_log_level
  end

  LOG_LEVELS = {
    :silence => -1,
    :error  => 1,
    :warn   => 2,
    :info   => 3,
    :debug  => 4
  }

  def error *args
    log :error, *args
  end

  def warn *args
    log :warn, *args
  end

  def info *args
    log :info, *args
  end

  def debug *args
    log :debug, *args
  end

  def log log_level, *args
    args.each do |object|
      log_object log_level, object
    end

    nil
  end

  private

  def self._instance
    Thread.current[:logger] ||= new
  end


  def log_object msg_log_level, object
    return nil if numeric_log_level(msg_log_level) > numeric_log_level(log_level)

    string = if object.is_a?(Exception)
      "#{object.class} #{object.message}\n#{object.backtrace.join("\n")}"
    elsif object.is_a? String
      object
    elsif object.is_a?(Array) || object.is_a?(Hash)
      "#{JSON.pretty_generate object}"
    else
      "#{object.class} #{object.to_s}"
    end

    string.split("\n").each do |line|
      puts "[#{msg_log_level}] #{line}"
    end

    nil
  end

  def numeric_log_level log_level
    LOG_LEVELS[log_level.to_sym]
  end


end
