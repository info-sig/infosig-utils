if defined?(Sequel::Model)
  class Sequel::Model
    module Resolvable
      extend ActiveSupport::Concern

      class Unresolvable < StandardError; end

      included do
        dataset_module do
          def resolve obj, options = {}
            if obj.class == model
              rv = obj
            elsif obj.class == String
              rv = where(logid: obj).first
            elsif obj.class == Integer
              rv = where(id: obj).first
            end
            if !rv && options[:raise]
              raise Unresolvable.new("can't resolve #{obj.class} #{obj.inspect}")
            end

            rv
          end

          def resolve_id obj, options = {}
            if obj.class == model
              rv = obj.id
            elsif obj.class == String
              rv = where(logid: obj).pluck(:id).first
            elsif obj.class == Integer
              rv = id
            end
            if !rv && options[:raise]
              raise Unresolvable.new("can't resolve #{obj.class} #{obj.inspect}")
            end

            rv
          end
        end
      end

    end
  end
end