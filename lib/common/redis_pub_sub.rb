module RedisPubSub

  def self.publish key, value, opts = {}
    timeout = opts[:timeout] || 10
    redis_key = CacheKey[key]
    redis_sub_key = redis_key + "/sub"
    json_msg = value.to_json

    REDIS.with do |redis|
      redis.multi do
        redis.setex(redis_key, timeout, json_msg)
        puts "#{key} - setex"
        redis.publish(redis_sub_key, json_msg)
        puts "#{key} - publish"
      end
    end
  end

  def self.subscribe key, opts = {}
    Fetch[key, opts]
  end

end