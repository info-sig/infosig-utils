class Retryer
  extend ClassFunctional

  def self.call(options = {}, &block)
    repeats, sleeps = repeats_sleeps options
    count = 0
    rv = {}
    while count < repeats
      rv = retry_once(&block)
      return rv[:rv] if rv[:status] == 'OK'
      count = count + 1
      warn "#{rv[:exception].class}: #{rv[:exception].message}, retry #{count} of #{repeats}"
      sleep sleeps
    end
    raise rv[:exception]
  end

  def self.repeats_sleeps(options)
    return options[:repeats] || 2, options[:sleeps] || 0.seconds
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