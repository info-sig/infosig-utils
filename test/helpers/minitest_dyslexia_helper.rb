module MinitestDyslexiaHelper

  require "active_support/concern"
  extend ActiveSupport::Concern

  included do
    class << self
      alias_method :setup, :before
      alias_method :teardown, :after
    end

    alias_method :assert_raise, :assert_raises
  end

end