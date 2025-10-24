class InMemoryStorageTest < UnitTest
  setup do
    @storage = InMemoryStorage.new
  end

  def test_get_set
    assert_nil @storage.get("key"), "Initial value should be nil"
    
    @storage.set("key", "value")
    assert_equal "value", @storage.get("key"), "Get should return set value"
    
    @storage.set("key", 123)
    assert_equal 123, @storage.get("key"), "Get should return updated value"
  end

  def test_incr_decr
    assert_nil @storage.get("counter"), "Initial value should be nil"
    
    # First increment
    assert_equal 1, @storage.incr("counter"), "First increment should return 1"
    assert_equal 1, @storage.get("counter"), "Get should return incremented value"
    
    # Second increment
    assert_equal 2, @storage.incr("counter"), "Second increment should return 2"
    
    # Decrement
    assert_equal 1, @storage.decr("counter"), "Decrement should return 1"
    assert_equal 1, @storage.get("counter"), "Get should return decremented value"
    
    # Increment different key
    assert_equal 1, @storage.incr("other_counter"), "Increment on new key should return 1"
    assert_equal 1, @storage.get("other_counter"), "Get should return correct value for other key"
    assert_equal 1, @storage.get("counter"), "Original counter should be unchanged"
  end

  def test_expire
    @storage.set("expiring_key", "value")
    assert_equal "value", @storage.get("expiring_key")
    
    @storage.expire("expiring_key", 1)
    assert_equal "value", @storage.get("expiring_key"), "Value should exist before expiry"
    
    Timecop.travel(Time.now + 1.1) # Wait for expiry
    
    assert_nil @storage.get("expiring_key"), "Value should be nil after expiry"
  ensure
    Timecop.return
  end

  def test_expire_with_multiple_keys
    @storage.set("key1", "value1")
    @storage.set("key2", "value2")
    
    @storage.expire("key1", 1)
    
    Timecop.travel(Time.now + 1.1) # Wait for key1 to expire
    
    assert_nil @storage.get("key1"), "key1 should be nil after expiry"
    assert_equal "value2", @storage.get("key2"), "key2 should still exist"
  ensure
    Timecop.return
  end

  def test_nonexistent_key_expire
    result = @storage.expire("nonexistent", 10)
    assert_equal false, result, "Expire on nonexistent key should return false"
  end

  def test_get_incr_on_nonexistent_key
    assert_nil @storage.get("nonexistent"), "Get on nonexistent key should return nil"
    assert_equal 1, @storage.incr("nonexistent"), "Incr on nonexistent key should initialize to 1"
  end

  def test_decr_below_zero
    @storage.set("counter", 1)
    assert_equal 0, @storage.decr("counter"), "First decrement should return 0"
    assert_equal -1, @storage.decr("counter"), "Second decrement should return -1"
  end
end