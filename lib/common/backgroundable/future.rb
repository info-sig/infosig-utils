module Backgroundable
  module Futuristic
    extend ActiveSupport::Concern
    include Backgroundable

    included do |base|
      fqdn = base.name

      class_eval <<-RUBY
        class #{fqdn}::Future < #{fqdn}
          include Futuristic
        end

      RUBY
    end

    def perform *args, &block
      opts = ExtractOptions[args]
      rv = call(*args, &block)
      RedisPubSub.publish("Backgroundable::Future/#{jid}", rv, opts)
    end


    module ClassMethods

      def execute *args
        opts = ExtractOptions[args]
        jid = perform_async *args
        Concurrent::Future.execute do
          RedisPubSub.subscribe("Backgroundable::Future/#{jid}", opts)
        end
      end

    end

  end
end