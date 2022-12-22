require "test_helpers"

class RedisPubSubTest < UnitTest

  # parallelize_me!

  setup do
  end

  def test_basic_sync_use
    RedisPubSub.publish("foo", 'abc')
    act = RedisPubSub.subscribe("foo")
    assert_equal 'abc', act, 'subscribe didnt return a good value'

    act = Concurrent::Future.execute{ RedisPubSub.subscribe("foo") }
    sleep 0.5
    RedisPubSub.publish("foo", 'abc')
    assert_equal 'abc', act.value!, 'subscribe didnt return a good value'
  end

  def test_under_pressure
    x = 10
    pub_fs = x.times.map{ |idx| Concurrent::Future.execute{ RedisPubSub.publish("foo/#{idx}", idx) } }
    sub_fs = x.times.map{ |idx| Concurrent::Future.execute{ RedisPubSub.subscribe("foo/#{idx}") } }
    assert_equal x.times.map{|idx| idx}, sub_fs.map(&:value!), 'all X threads received good responses'
  end

end