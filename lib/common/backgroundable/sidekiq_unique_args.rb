require_relative '../class_functional'

module Backgroundable
  class SidekiqUniqueArgs
    extend ClassFunctional
    def self.call *args
      if InfoSig.env == :test
        rv = [Thread.current[:test_run_uid]] + args
      else
        rv = args
      end

      rv
    end
  end
end