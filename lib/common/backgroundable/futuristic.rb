module Backgroundable
  module Futuristic
    extend ActiveSupport::Concern
    include Backgroundable


    module FuturisticMethods
      def perform method, *args
        opts = ExtractOptions[args]
        args_for_send = *args

        # if the perform included an added options = {} hash and that makes the receiving function go all weird, remove
        # the options hash from the end
        args_for_send.pop if !opts.empty? && method(method).arity < args_for_send.count

        rv = send(method, *args_for_send)
        # puts "RedisPubSub.publish(\"Backgroundable::Future/#{jid}\", #{rv}, #{opts})"
        RedisPubSub.publish("Backgroundable::Future/#{jid}", rv, opts)
        rv
      end
    end

    module FuturisticClassMethods
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

    included do |base|
      fqdn = base.name

      class_eval <<-RUBY
        class #{fqdn}::Future < #{fqdn}
          include Futuristic
          include FuturisticMethods
          extend FuturisticClassMethods
        end

      RUBY
    end

  end
end