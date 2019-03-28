class Cache

  DEFAULT_EXPIRE_IN = 15.minutes.to_i

  attr_reader :redis

  def initialize redis_connection_pool, options = {}
    @redis = redis_connection_pool
    @namespace = options.delete(:namespace) || 'cache'
  end

  def fetch key, options = {}
    value = @redis.with{ |redis| redis.get(k(key)) }

    if value
      # InfoCoin.log.debug "cache hit for #{key}"
      value
    else
      # InfoCoin.log.debug "cache miss for #{key}"
      if block_given?
        value = yield
        write key, value, options
      end
    end

    return value
  end

  def write key, value, options = {}
    expire_in = options.delete(:expire_in) || DEFAULT_EXPIRE_IN

    @redis.with do |redis|
      redis.multi do |redis|
        redis.set(k(key), value)
        redis.expire(k(key), expire_in.to_i)
      end
    end

    value
  end

  def expire key
    @redis.with{ |redis| redis.del(k(key)) }
  end

  def ttl key
    @redis.with{ |redis| redis.ttl(k(key)) }
  end


  private

  def k(key)
    @namespace + "/" + key
  end

end