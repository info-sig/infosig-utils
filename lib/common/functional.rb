module Functional
  extend ActiveSupport::Concern

  def method_call
    method(:call)
  end

  delegate :>>, :<<, to: :method_call

  alias_method :as_proc, :method_call

  def [] *args, &block
    call(*args, &block)
  end


  module ClassMethods

    delegate :call, :[], :method_call, :as_proc, :<<, :>>,
      to: :new

    def future *args, &block
      Concurrent::Future.execute{ call(*args, &block) }
    end

  end

end