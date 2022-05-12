class Retryer
  extend ClassFunctional

  def self.call options = {}, &block
    repeats = options[:repeats] || 3
    sleeps  = options[:sleeps]  || 0.seconds

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


  private

  def self.retry_once &block
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
