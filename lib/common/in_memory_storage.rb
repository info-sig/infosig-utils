# Simple in-memory storage adapter that implements Redis-like interface
class InMemoryStorage
  def initialize
    @data = {}
    @expiry = {}
  end

  # pretend you're fetching a connection
  def with
    yield self
  end

  def get(key)
    cleanup_expired
    @data[key]
  end

  def set(key, value)
    cleanup_expired
    @data[key] = value
  end

  def incr(key)
    cleanup_expired
    @data[key] = (@data[key] || 0).to_i + 1
  end

  def decr(key)
    cleanup_expired
    @data[key] = (@data[key] || 0).to_i - 1
  end

  def expire(key, seconds)
    return false unless @data.key?(key)
    @expiry[key] = Time.now + seconds
    true
  end

  private

  def cleanup_expired
    now = Time.now
    @expiry.each do |key, expiry_time|
      if expiry_time <= now
        @data.delete(key)
        @expiry.delete(key)
      end
    end
  end
end