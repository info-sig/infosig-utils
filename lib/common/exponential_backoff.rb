class ExponentialBackoff
  extend ClassFunctional

  class FailedExecution < RuntimeError; end

  def self.call opts = {}
    opts = opts.clone
    opts[:max_sleep] ||= 5
    opts[:timeout]   ||= 10 # seconds

    next_sleep  = 0.1
    total_sleep = 0

    ctx = {
      opts: opts,
      rv: nil,
      count: 0,
      slept: 0
    }

    wrap_yield(ctx){ yield }

    until total_sleep >= opts[:timeout]
      rv = wrap_yield(ctx){ yield }
      # puts "rv: #{rv.inspect} \t\t sleep: #{next_sleep} #{total_sleep}/#{opts[:max_sleep]}"
      return rv unless rv.is_a?(FailedExecution)

      sleep next_sleep

      total_sleep += next_sleep
      next_sleep = [next_sleep*1.5, opts[:max_sleep]].min
      if total_sleep + next_sleep > opts[:timeout]
        next_sleep = total_sleep + next_sleep - opts[:max_sleep]
      end
    end

    ctx[:rv]
  end


  private

  def self.wrap_yield ctx
    ctx[:rv] = yield
    ctx[:rv]
  rescue Exception => e
    ctx[:count] += 1
    ctx[:error] = "ExponentialBackoff failure ##{ctx[:count]} #{e.class}: #{e.message}"
    ctx[:exception] = e

    STDERR.puts(ctx[:error]) unless ctx.dig(:opts, :nolog)
    return FailedExecution.new(ctx[:error])
  end

end