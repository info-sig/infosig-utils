class Retryer
  extend ClassFunctional

  def self.call(options = {}, &block)
    no_of_repeats_and_sleep_duration = no_of_repeats_and_sleep_duration(options)
    no_of_repeats = no_of_repeats_and_sleep_duration.delete(:no_of_repeats)
    sleep_duration = no_of_repeats_and_sleep_duration.delete(:sleep_duration)
    count = 0
    rv = {}
    while count < no_of_repeats
      rv = retry_once(&block)
      return rv[:rv] if rv[:status] == 'OK'
      count = count + 1
      warn "#{rv[:exception].class}: #{rv[:exception].message}, retry #{count} of #{no_of_repeats}"
      sleep sleep_duration
    end
    raise rv[:exception]
  end

  def self.no_of_repeats_and_sleep_duration(options)
    return {
      no_of_repeats: options[:repeats] || 2,
      sleep_duration: options[:sleeps] || 0.seconds
    }
  end

  private

  def self.retry_once(&block)
    {
      rv: block.call,
      status: 'OK'
    }
  rescue Exception => e
    {
      exception: e,
      status: 'error'
    }
  end
end