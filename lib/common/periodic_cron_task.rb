class PeriodicCronTask

  attr_accessor :cron_task_state
  attr_accessor :execution_options

  # see example usage in event_mailer
  def self.call(*args, &block)
    new(*args).call(&block)
  end

  def initialize(task, options = {})
    options = options.dup

    options[:every]     ||= 5.minutes
    path = options[:path] ||= "/cron_task_states/cron_task_state_for_#{task}.yml"
    default_last_run_time = options[:default_last_run_time] ||= Time.now - options[:every] * 2

    self.execution_options = options
    self.cron_task_state   = JSON.parse(REDIS.with{ |redis| redis.get(path) }).with_indifferent_access rescue {}

    cron_task_state[:last_run_time] ||= default_last_run_time
    cron_task_state[:this_run_time] = Time.now
    cron_task_state[:time_frame]    = (to_time(cron_task_state[:last_run_time])...to_time(cron_task_state[:this_run_time]))
  end

  def call
    yield cron_task_state, execution_options

    cron_task_state[:last_run_time] = cron_task_state[:this_run_time]

    REDIS.with{ |redis| redis.set(execution_options[:path], cron_task_state.to_json) }

    self
  end

  private


  def to_time time
    if time == nil
      nil
    elsif time.is_a?(String)
      Time.parse(time)
    else # is a date/time
      time
    end
  end

end