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

    def perform *args
      opts = ExtractOptions[args]
      rv = call(*args)
      # puts "RedisPubSub.publish(\"Backgroundable::Future/#{jid}\", #{rv}, #{opts})"
      RedisPubSub.publish("Backgroundable::Future/#{jid}", rv, opts)
      rv
    end


    module ClassMethods

      def execute *args
        opts = ExtractOptions[args]
        jid = perform_async *args
        Concurrent::Future.execute do
          # puts "RedisPubSub.subscribe(\"Backgroundable::Future/#{jid}\", #{opts})"
          rv = RedisPubSub.subscribe("Backgroundable::Future/#{jid}", opts)
          # puts "    #{jid} rv=#{rv}"
          rv
        end
      end

    end

  end
end