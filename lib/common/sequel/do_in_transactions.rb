module Sequel
  class DoInTransactions
    include Functional

    def call enumerable, options = {}, &block
      size = options.delete(:size) || 1000
      on_commit = options.delete(:on_commit) || ->(buffer){}

      buffer = []

      process_buffer = ->(buffer) do
        DB.transaction do
          buffer.each do |buffer_el|
            yield buffer_el
          end
          on_commit[buffer]
          buffer.clear
        end
      end

      enumerable.each do |enumerable_el|
        buffer << enumerable_el if enumerable_el
        process_buffer[buffer, &block] if buffer.length >= size
      end
      process_buffer[buffer, &block] if buffer.any?

    end

  end
end
