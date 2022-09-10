# frozen_string_literal: true

module TokensManager
  class Resizer
    module Models
      class BasicTokenDetails
        include Concerns::Placeholderable

        attr_reader :grouped_variants

        def initialize(value:, witnesses_ids:)
          @value = without_placeholders(value:)
          @witnesses_ids = witnesses_ids
          @grouped_variants = GroupedVariantsGenerator.perform(token: self)
        end

        def variants
          @variants ||= witnesses_ids.map do |witness|
            TokenVariant.new(t: value, witness:)
          end
        end

        def editorial_remark
          nil
        end

        private

        attr_reader :value, :witnesses_ids
      end
    end
  end
end
