require "minitest/autorun"
require "rack/test"
require 'sidekiq/testing'
$PARALLEL_EXECUTION = false
require_relative 'helpers/parallel_executor' if ENV['PARALLEL']

require_relative 'application/environment'
require_relative '../lib/infosig-utils'

# Load the App in the appropriate ENV
ENV['RACK_ENV'] = 'test'

class UnitTest < MiniTest::Spec

  require_relative "helpers/minitest_dyslexia_helper"
  include MinitestDyslexiaHelper
  require_relative "helpers/multi_threaded"
  include MultiThreaded

  make_my_diffs_pretty!

  def run(*args, &block)
    if multi_threaded?
      # printf "!"
      super
    else
      # printf ","
      # Sequel::Model.db.transaction(:rollback=>:always, :auto_savepoint=>true) do
      #   # DB[:raw_messages].delete if DB[:raw_messages].count > 0 # hack hack hack: the raw messages get stored in a separate thread, this is a drkaround
      #   super
      # end
      super
    end
  end

  before do
    Thread.current[:test_run_uid] = @test_run_uid = self.class.to_s.underscore + "/" + name.gsub(/^test_[0-9]+_/, 'test_it_') + "/" + SecureRandom.hex
    $test_run_uid = SecureRandom.uuid.freeze
  end

  after do
    $pry = false
  end

  def self.skip_stress_tests?
    ENV['SKIP_STRESS_TESTS'] || ENV['SKIP_SLOW_TESTS']
  end

  def pry!
    $pry = true
  end

  def join_messages *messages
    messages.compact.join(': ')
  end

  def trace_of_all_events scope = Event
    scope.all.map(&:pretty_trace).join("\n")
  end

  def assert_equal_or_nil exp, act, msg = 'is bonky'
    if exp
      assert_equal exp, act, msg
    else
      assert_nil act, msg
    end
  end

end

# Load the helpers
Dir["./test/helpers/*.rb"].sort.each {|file| require file }

# Print statistics in the end
unless $PARALLEL_EXECUTION
  Minitest.after_run do
    puts
    # TODO: custom reporters
  end
end
