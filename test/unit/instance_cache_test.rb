require "test_helpers"

class InstanceCacheTest < UnitTest

  X = InstanceCache


  def test_use
    cache = nil
    assert_equal 1, X.call(cache, 1){ 1 }

    cache = {}
    assert_equal 1, X.call(cache, 1){ 1 }
    assert_equal 1, X.call(cache, 1){ raise "wii" }
    assert_equal 2, X.call(cache, 2){ 2 }

    cache = {}
    assert_equal 1, X.call(cache, 1){ 1 }
    assert_equal 1, X.call(cache, 1){ raise "wii" }
    assert_equal 2, X.call(cache, 2){ 2 }

    cache = SafeHash.new
    assert_equal 1, X.call(cache, 1){ 1 }
    assert_equal 1, X.call(cache, 1){ raise "wii" }
    assert_equal 2, X.call(cache, 2){ 2 }

    cache = nil
    assert_equal 2, X.call(cache, 1){ 2 }
  end

end
