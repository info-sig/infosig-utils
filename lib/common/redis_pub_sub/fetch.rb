module RedisPubSub
  class Fetch
    extend ClassFunctional
    # include ValidationRaisable

    def self.call key, options = {}
      clean_redis = true
      timeout = options.delete(:timeout) || 10
      nil_on_timeout = options.delete(:nil_on_timeout)
      redis_key = CacheKey[key]

        # Step 1: do we have something already persisted?
      puts "#{key} - 1 - get"
      rv = REDIS.with{|redis| redis.get(redis_key)}
      return parse_result(rv) if rv

      (timeout*10).times do
        rv = listen_and_get key, redis_key, timeout
        sleep 0.1
        return rv if rv
      end

      # Step 4: give up, drink beer, break process
      puts "#{key} - 4 - raise or nil"
      if nil_on_timeout
        return nil
      else
        raise Timeout::Error.new("no callback received for #{key}")
      end

    rescue Exception => e
      clean_redis = false
      raise e

    ensure
      if clean_redis
        puts "#{key} - del"
        REDIS.with do |redis|
          redis.del(key)
        end
      end

    end


    private

    def self.listen_and_get key, redis_key, timeout
      # rv = nil
      # redis_sub_key = redis_key + "/sub"
      #
      # puts "#{key} - 2 - subscribe"
      # begin
      #   REDIS.with do |redis|
      #     redis.subscribe_with_timeout(1, redis_sub_key) do |on|
      #       on.message do |_, msg|
      #         rv = msg
      #         redis.unsubscribe
      #       end
      #     end
      #   end
      # rescue Redis::TimeoutError
      #   :-/
      # end
      #
      # return parse_result(rv) if rv

      puts "#{key} - 3 - get again"
      rv = REDIS.with{|redis| redis.get(redis_key)}
      return parse_result(rv) if rv
    end

    def self.parse_result str
      rv = JSON.parse(str)
      puts "#{rv} - OK"
      rv
    end

  end
end