# frozen_string_literal: true

module TokensManager
  class Resizer
    module Models
      class BasicTokenDetails
        attr_reader :variants, :grouped_variants

        def initialize(value:, witnesses_ids:)
          @variants = generate_variants(value, witnesses_ids)
          @grouped_variants = GroupedVariantsGenerator.perform(token: self)
        end

        def editorial_remark
          nil
        end

        private

        def processed_value(value)
          ProcessedString.new(string: value).string
        end

        def generate_variants(value, witnesses_ids)
          value = processed_value(value)
          witnesses_ids.map do |witness|
            TokenVariant.new(t: value, witness:)
          end
        end
      end
    end
  end
end
