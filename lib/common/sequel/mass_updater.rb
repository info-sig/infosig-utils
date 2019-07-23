module Sequel
  class MassUpdater
    include Functional
    include ValidationRaisable

    def call scope, attrs
      DoInTransactions.call(scope.use_cursor(:rows_per_fetch=>1000)) do |record|
        old_values = record.values.with_indifferent_access.slice(*attrs.keys)
        new_values = attrs
        changes = attrs.keys.inject([]) do |sum, k|
          sum << [old_values[k], new_values[k]]
          sum
        end
        record.update(new_values)
        yield(record, changes)
      end
    end
  end
end