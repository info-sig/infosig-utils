module RedisPubSub

  class NoAnswerException < RuntimeError; end

  def self.publish key, value, opts = {}
    opts = opts.with_indifferent_access
    timeout = opts[:timeout] || 10
    EnforceType[timeout, Integer]
    redis_key = CacheKey[key]
    json_msg = value.to_json

    REDIS.with do |redis|
      # puts "redis.setex(#{redis_key}, #{timeout}, #{json_msg})"
      redis.setex(redis_key, timeout, json_msg)
    end
  end

  def self.subscribe key, opts = {}
    Fetch[key, opts]
  end

end