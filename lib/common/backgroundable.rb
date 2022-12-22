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

    def sidekiq_future *args
      rv = perform_async *args
    end
  end


  private

  def calculate_job_id custom_uuid
    return custom_uuid if custom_uuid

    wrapped_jid = respond_to?(:jid) ? jid : nil
    rv = wrapped_jid || SecureRandom.uuid
    rv
  end


end
