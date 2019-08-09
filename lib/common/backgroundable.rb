module Backgroundable
  extend ActiveSupport::Concern

  include Functional

  included do
    if defined?(Sidekiq)
      include Sidekiq::Worker
    else
      warn "Sidekiq not loaded"
    end
  end

  def perform *args, &block
    call(*args, &block)
  end

  module ClassMethods
    def call_async timing, *args, &block
      if timing == :inline
        call(*args, &block)
      elsif timing == :future
        future(*args, &block)
      elsif timing == :async
        perform_async(*args, &block)
      else
        raise ArgumentError.new("expected timing to be :inline, :future, :async. TODO support for a time/interval object")
      end
    end
  end


end
