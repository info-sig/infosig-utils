module RedisPubSub
  class Fetch
    extend ClassFunctional
    # include ValidationRaisable

    def self.call key, opts = {}
      opts = opts.with_indifferent_access
      clean_redis = true
      timeout = opts.delete(:timeout) || 10
      nil_on_timeout = opts.delete(:nil_on_timeout)
      max_sleep = opts.delete(:max_sleep) || 2
      redis_key = CacheKey[key]

      # Step 1: do we have something already persisted?
      # puts "#{key} - 1 - get"
      rv = REDIS.with{|redis| redis.get(redis_key)}
      return parse_result(rv) if rv

      # idx = 0
      ExponentialBackoff.call(timeout: timeout, max_sleep: max_sleep, nolog: true) do
        # puts "#{key} - 3 - get again ##{idx+=1}"
        rv = REDIS.with{|redis| redis.get(redis_key)}
        return parse_result(rv) if rv
        raise RedisPubSub::NoAnswerException
      end

      # Step 4: give up, drink beer, break process
      # puts "#{key} - 4 - raise or nil"
      if nil_on_timeout
        return nil
      else
        raise Timeout::Error.new("no response received for #{key}")
      end

    rescue Exception => e
      clean_redis = false
      raise e

    ensure
      if clean_redis
        # puts "#{key} - del"
        REDIS.with do |redis|
          redis.del(key)
        end
      end

    end


    private

    def self.parse_result str
      rv = JSON.parse(str)
      # puts "#{rv} - OK"
      rv
    end

  end
end