class AppLogger
  attr_accessor :file

  def initialize opts = {}
    @file = opts[:file]
  end

  module Helpers
    extend ActiveSupport::Concern
    def log
      AppLogger
    end

    def D string
      log.debug string
    end

    module ClassMethods
      include Helpers
    end
  end

  class << self
    delegate :log, :info, :error, :debug, :warn, :file, :close,
      to: :_instance
  end

  cattr_accessor :log_level, :log_message
  #delegate :log_level, to: 'self.class'

  # !!!! NOT FOR PRODUCTION USE !!!!
  def self.with_log_level tmp_log_level
    old_log_level = self.log_level
    self.log_level = tmp_log_level
    yield
  ensure
    self.log_level = old_log_level
  end

  def self.filtered_log_level *args
    args = args[0] if args[0].is_a?(Array)
    raise ArgumentError.new("There must be at least 2 elements present") if args.length < 2
    text_msg = args.pop
    raise ArgumentError.new("First element must be one of the following: #{LOG_LEVELS.keys}") unless (args - LOG_LEVELS.keys).empty?
    raise ArgumentError.new("Last element must be a string message") unless text_msg.is_a?(String)

    old_log_level = self.log_level
    self.log_level = args
    self.log_message = text_msg
    yield
  ensure
    self.log_level = old_log_level
    self.log_message = []
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
      if log_message.nil?
        log_object log_level, object
      else
        log_filtered_object log_level, object, log_message
      end
    end

    nil
  end

  def close
    file.close unless file == STDOUT
  end

  private

  def self._instance
    Thread.current[:logger] ||= new
  end


  def log_object msg_log_level, object
    return nil if numeric_log_level(msg_log_level) > numeric_log_level(log_level)

    log_stout object, msg_log_level
    nil
  end

  def log_filtered_object msg_log_level, object, log_message
    self.log_level = [self.log_level] unless self.log_level.is_a?(Array)
    self.log_level.each do |level|
      next unless object_should_be_logged_for_log_level?(msg_log_level, level, log_message, object)
      return nil
    end

    log_stout object, msg_log_level
    nil
  end

  def object_should_be_logged_for_log_level?(msg_log_level, level, log_message, object)
    numeric_log_level(msg_log_level) == numeric_log_level(level) && object.include?(log_message)
  end

  def log_stout object, msg_log_level
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
      if file
        file.puts "[#{msg_log_level}] #{line}"
      else
        puts "[#{msg_log_level}] #{line}"
      end
    end

    nil
  end

  def numeric_log_level log_level
    LOG_LEVELS[log_level.to_sym]
  end


end
