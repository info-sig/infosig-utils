require "test_helpers"
require "timecop"

class ExecutionSemaphoreTest < UnitTest
  parallelize_me!

  setup do
    @storage = [ InMemoryStorage.new, REDIS ].sample
    @semaphore = ExecutionSemaphore.new(@storage, "test_semaphore")
  end

  def test_basic_increment_decrement
    assert_equal 0, @semaphore.current_count, "[#{@storage.class.name}] Initial count should be 0"
    
    @semaphore.inc
    assert_equal 1, @semaphore.current_count, "[#{@storage.class.name}] Count should be 1 after increment"
    
    @semaphore.inc
    assert_equal 2, @semaphore.current_count, "[#{@storage.class.name}] Count should be 2 after second increment"
    
    @semaphore.dec
    assert_equal 1, @semaphore.current_count, "[#{@storage.class.name}] Count should be 1 after decrement"
    
    @semaphore.dec
    assert_equal 0, @semaphore.current_count, "[#{@storage.class.name}] Count should be 0 after second decrement"
  end

  def test_with_semaphore_block
    result = nil
    
    @semaphore.with_semaphore do
      assert_equal 1, @semaphore.current_count, "[#{@storage.class.name}] Count should be 1 inside block"
      result = "executed"
    end
    
    assert_equal "executed", result, "[#{@storage.class.name}] Block should have executed"
    assert_equal 0, @semaphore.current_count, "[#{@storage.class.name}] Count should be 0 after block completes"
  end

  def test_with_semaphore_ensures_decrement
    begin
      @semaphore.with_semaphore do
        assert_equal 1, @semaphore.current_count, "[#{@storage.class.name}] Count should be 1 inside block"
        raise "Test exception"
      end
    rescue StandardError => e
      assert_equal "Test exception", e.message
    end
    
    assert_equal 0, @semaphore.current_count, "[#{@storage.class.name}] Count should be 0 even after exception in block"
  end

  def test_max_entries_with_exception
    semaphore = ExecutionSemaphore.new(@storage, "limited_semaphore", max_entries: 2)
    
    semaphore.inc
    assert_equal 1, semaphore.current_count, "[#{@storage.class.name}] Count should be 1"
    
    semaphore.inc
    assert_equal 2, semaphore.current_count, "[#{@storage.class.name}] Count should be 2"
    
    assert_raises(ExecutionSemaphore::MaxEntriesExceededError) do
      semaphore.inc
    end
    
    assert_equal 2, semaphore.current_count, "[#{@storage.class.name}] Count should remain at max after failed increment"
  end

  def test_max_entries_with_skip
    semaphore = ExecutionSemaphore.new(@storage, "skip_semaphore", max_entries: 1)
    
    result1 = semaphore.with_semaphore do
      "first execution"
    end
    
    assert_equal "first execution", result1, "[#{@storage.class.name}] First execution should complete"
    
    # This should execute the first block and hold the lock
    executing = false
    thread = Thread.new do
      semaphore.with_semaphore do
        executing = true
        sleep 0.5  # Hold the lock for a moment
        "thread execution"
      end
    end
    
    # Wait for the thread to acquire the lock
    sleep 0.1 until executing
    
    # This should skip execution since max_entries is reached
    result2 = semaphore.with_semaphore(skip_if_max: true) do
      "should not execute"
    end
    
    assert_nil result2, "[#{@storage.class.name}] Block should have been skipped"
    
    # Wait for the thread to complete
    thread.join
    
    # Now we should be able to execute again
    result3 = semaphore.with_semaphore do
      "third execution"
    end
    
    assert_equal "third execution", result3, "[#{@storage.class.name}] Third execution should complete"
  end

  def test_negative_count_prevention
    # Force count to go negative by calling dec without inc
    @semaphore.dec
    assert_equal 0, @semaphore.current_count, "[#{@storage.class.name}] Count should not go below 0"
  end

  def test_expiry
    semaphore = ExecutionSemaphore.new(@storage, "expiring_semaphore", expiry: 1)
    
    semaphore.inc
    assert_equal 1, semaphore.current_count, "[#{@storage.class.name}] Count should be 1"
    
    sleep 1.1
    
    assert_equal 0, semaphore.current_count, "[#{@storage.class.name}] Count should reset after expiry"
  end
end
