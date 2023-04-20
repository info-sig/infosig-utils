class Retryer
  extend ClassFunctional

  def self.call(options = {}, &block)
    no_of_repeats, sleep_duration = no_of_repeats_and_sleep_duration(options)

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
    return options[:repeats] || 2, options[:sleeps] || 0.seconds
  end

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