require_relative '../validation_raisable'
require_relative '../class_functional'

class Hash
  class EnforceSafeKeys
    extend ClassFunctional
    include ValidationRaisable

    def self.call safe_attributes, arg_attributes
      attrs = arg_attributes.inject(HashWithIndifferentAccess.new) do |sum, x|
        k, v = x
        k = k.to_s
        if safe_attributes.include?(k)
          sum[k] = v
        else
          validation_error("Protected field: #{k} - set the safe_attributes argument if you are certain")
        end
        sum
      end

      attrs
    end
  end
end