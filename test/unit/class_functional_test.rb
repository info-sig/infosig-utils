require 'test_helpers'

class ClassFunctionalTest < UnitTest

  # THIS CLASS IS A RAMDA TEST ZoNE - by the author himself, Ramda is stable, but not production-ready
  # lets use it in a limited fashion
  R = Ramda

  class AddN
    extend ClassFunctional
    def self.call *args
      args.inject(0){ |sum, arg| sum += arg }
    end
  end

  class Add2
    extend ClassFunctional
    def self.call a, b
      a + b
    end
  end

  setup do
    @addN = lambda do |*args|
      args.inject(0){ |sum, arg| sum += arg }
    end

    @add2 = lambda do |a, b|
      a + b
    end
  end

  def test_calling_a_functional_class
    assert_equal 8,  AddN.call(3, 5), '#call result is off'
    assert_equal 11, AddN[4, 4, 3],  '#[] result is off'

    # just for good measure to see if the lambda is good
    assert_equal 6, @addN[1,2,3], 'the factory proc is bad'
  end

  def test_currying_with_functional_class_vs_currying_with_proc
    assert_equal 8, R.curry(AddN.as_proc)[3, 5], '[., .] result is off with a *args proc'

    assert Add2.as_proc.curry[3].is_a?(Proc), 'curry should be a proc'

    assert_equal 7, R.curry(Add2.as_proc)[3][4], '[.][.] is off'
    assert_equal 8, R.curry(Add2.as_proc)[3][5], '[.][.] is off'
    assert_equal 9, R.curry(@add2)[3][6], '[.][.] is off'

    add_number_5 = R.curry(Add2.as_proc)[5]
    assert_equal 10, add_number_5[5], 'partial function application is off'

    add_number_5 = R.curry(Add2.as_proc).curry[6]
    assert_equal 11, add_number_5[5], 'partial function application is off'
  end

  def test_composition
    add_number_3 = R.curry(Add2.as_proc)[3]
    add_number_4 = R.curry(Add2.as_proc)[4]
    add_number_5 = R.curry(@add2)[5]
    add_number_7 = 7.method(:+)

    add_number_15 = R.pipe(add_number_5, add_number_3, add_number_7, add_number_4)
    assert_equal 22, add_number_15[3], 'composed function has a funny result'
  end

end
