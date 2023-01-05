require "test_helpers"

class MemoizeTest < UnitTest

  def test_user_story
    @m ||= Memoize.new

    assert_equal 1, @m.call(expire_in: 1.minute){ 1 }.value, 'should have executed { 1 }'
    assert_equal 1, @m.call(expire_in: 1.minute){ 2 }.value, 'should have fetched from cache'

    Timecop.travel(1.minute)
    assert_equal 2, @m.call(expire_in: 1.minute){ 2 }.value, 'should have executed { 2 }'
  end

end
