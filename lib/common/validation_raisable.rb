module ValidationRaisable
  extend ActiveSupport::Concern

  class ValidationError < StandardError; end

  included do
    # this needs to be expressed as a string, or ruby will do funny things with the constant lookup tables
    # and will proclaim SomeClass::ValidationError to be actually a ValidationRaisable::ValidationError,
    # but we prefer the context of the class to be preserved in the exception (ie SomeClass::ValidationError)
    self.class_eval 'class ValidationError < ValidationRaisable::ValidationError; end'
  end


  module ClassMethods
    def validation_error message
      if defined?(Dry::Schema::Result) && message.is_a?(Dry::Schema::Result)
        string = message.errors.inject([]){|sum, x| k,v = x; sum << "#{k}: #{v.join(', ')}"}.join('; ')
        raise self::ValidationError.new(string)
      else
        raise self::ValidationError.new(message)
      end
    end

    def validate!(schema)
      schema.success? || validation_error(schema)
    end
  end

  def validation_error *args, &block
    self.class.validation_error(*args, &block)
  end

  def validate! *args, &block
    self.class.validate!(*args, &block)
  end

  
  extend ClassMethods
end