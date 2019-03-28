class Struct
  module HashConstructable
    extend ActiveSupport::Concern

    def set_all hash
      hash.each do |k, v|
        send("#{k}=", v)
      end
      self
    end

    module ClassMethods
      def from_hash hash
        raise ArgumentError.new('argument must be a hash') unless hash.is_a?(Hash)

        rv = new.set_all(hash)
        rv
      end

      alias_method :[], :from_hash
    end
  end
end