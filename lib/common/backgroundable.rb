module Backgroundable
  extend ActiveSupport::Concern

  include Functional

  included do
    include Sidekiq::Worker
  end

  def perform *args, &block
    call(*args, &block)
  end

end