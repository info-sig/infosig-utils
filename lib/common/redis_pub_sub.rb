module RedisPubSub

  class NoAnswerException < RuntimeError; end

  def self.publish key, value, opts = {}
    timeout = opts[:timeout] || 10
    redis_key = CacheKey[key]
    json_msg = value.to_json

    REDIS.with do |redis|
      redis.setex(redis_key, timeout, json_msg)
    end
  end

  def self.subscribe key, opts = {}
    Fetch[key, opts]
  end

end