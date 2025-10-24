# ExecutionSemaphore class that works with Redis-like storage backends
class ExecutionSemaphore

  # Initialize with a Redis-like storage object and optional configuration
  # @param storage [Object] Any object that implements get/set/incr/decr methods (Redis-like)
  # @param key [String] The key to use for storing the counter value
  # @param max_entries [Integer, nil] Maximum allowed concurrent executions (nil = unlimited)
  # @param expiry [Integer, nil] Optional TTL for the counter in seconds
  def initialize(storage, key, options = {})
    @storage = storage
    @key = key
    @max_entries = options[:max_entries]
    @expiry = options[:expiry]  || 1.day
  end

  # Increment the counter
  # @return [Integer] The new counter value
  def inc
    @storage.with do |conn|
      value = conn.incr(@key)
      conn.expire(@key, @expiry) if @expiry
      
      if @max_entries && value > @max_entries
        # Roll back the increment if we've exceeded max_entries
        conn.decr(@key)
        raise MaxEntriesExceededError, "Maximum concurrent executions (#{@max_entries}) exceeded"
      end
      
      value
    end
  end

  # Decrement the counter
  # @return [Integer] The new counter value
  def dec
    @storage.with do |conn|
      value = conn.decr(@key)
      # Ensure we don't go below zero
      if value < 0
        conn.set(@key, 0)
        return 0
      end
      value
    end
  end

  # Execute a block with the semaphore
  # @param skip_if_max [Boolean] If true, skip block execution when max_entries reached
  # @yield The block to execute
  # @return [Object] Result of the block or nil if skipped
  def with_semaphore(skip_if_max: false)
    begin
      inc
    rescue MaxEntriesExceededError => e
      return nil if skip_if_max
      raise e
    end

    begin
      yield
    ensure
      dec
    end
  end

  # Get the current counter value
  # @return [Integer] Current counter value
  def current_count
    @storage.with do |conn|
      value = conn.get(@key)
      value.nil? ? 0 : value.to_i
    end
  end

  # Custom error class for max entries exceeded
  class MaxEntriesExceededError < StandardError; end
end