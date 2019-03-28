require "test_helpers"

class CacheTest < UnitTest

  parallelize_me!

  setup do
    @cache = Cache.new(REDIS, namespace: "InfoSig/test/#{SecureRandom.uuid}")
  end

  def test_fetch
    key = 'test_fetch'
    msg_A = 'A'
    msg_B = 'B'

    # first fetch, cache miss
    assert_equal(-2, @cache.ttl(key), 'something is funny with the test setup')
    assert_nil @cache.fetch(key, expire_in: 1), 'first fetch wo/block went wrong'
    assert_equal msg_A, @cache.fetch(key, expire_in: 1){ msg_A }, 'first fetch w/block went wrong'
    assert_equal 1, @cache.ttl(key), 'wrong TTL after first fetch'

    # second fetch, cache hit
    assert_equal msg_A, @cache.fetch(key, expire_in: 1), 'second fetch wo/block went wrong'
    assert_equal msg_A, @cache.fetch(key, expire_in: 1){ msg_B }, 'second fetch w/block went wrong'

    # third fetch, after expiration
    sleep 1.1
    assert_equal(-2, @cache.ttl(key), 'something went funny with the expiration')
    assert_nil @cache.fetch(key, expire_in: 1), 'third fetch w/block went wrong (before block call)'
    assert_equal msg_B, @cache.fetch(key, expire_in: 1){ msg_B }, 'third fetch w/block went wrong'
    assert_equal msg_B, @cache.fetch(key, expire_in: 1), 'third fetch w/block went wrong (after block call)'
  end unless skip_stress_tests?

  def test_expire
    key = 'test_expire'
    msg_A = 'A'

    # first fetch, cache miss
    assert_equal(-2, @cache.ttl(key), 'something is funny with the test setup')
    assert_equal msg_A, @cache.fetch(key){ msg_A }, 'first fetch went wrong'
    assert_equal Cache::DEFAULT_EXPIRE_IN, @cache.ttl(key), 'wrong TTL after first fetch'

    # a miss after expire
    @cache.expire key
    assert_equal(-2, @cache.ttl(key), 'second fetch should have gotten nothing')
  end

  def test_write
    key = 'test_write'
    msg_A = 'A'
    msg_B = 'B'

    # first fetch, cache miss
    assert_equal(-2, @cache.ttl(key), 'something is funny with the test setup')
    assert_equal msg_A, @cache.fetch(key){ msg_A }, 'first fetch went wrong'
    assert_equal Cache::DEFAULT_EXPIRE_IN, @cache.ttl(key), 'wrong TTL after first fetch'

    # second fetch, cache hit & change
    assert_equal msg_A, @cache.fetch(key){ msg_B }, 'second fetch went wrong'
    @cache.write key, msg_B
    assert_equal msg_B, @cache.fetch(key){ msg_A }, 'second fetch went wrong'
  end

end