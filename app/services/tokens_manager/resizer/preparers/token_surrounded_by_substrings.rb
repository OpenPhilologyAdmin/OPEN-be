# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      class TokenSurroundedBySubstrings
        include TokensManager::Resizer::Preparers::Concerns::WithoutPlaceholders
        include TokensManager::Resizer::Preparers::Concerns::WithSurroundingValues

        def initialize(token:, value_before:, value_after:)
          @token = token
          @value_before = value_before
          @value_after = value_after
        end

        def self.perform(token:, value_before:, value_after:)
          new(token:, value_before:, value_after:).perform
        end

        def perform
          add_values_to_token_readings
          token
        end

        private

        attr_reader :token, :value_before, :value_after

        # all attributes that have :t
        def token_readings
          @token_readings = [
            token.variants, token.editorial_remark, token.grouped_variants
          ].flatten.compact
        end

        def add_values_to_token_readings
          token_readings.each do |resource|
            resource.t = processed_value(resource.t)
          end
        end

        def processed_value(value)
          without_placeholders(
            with_surrounding_values(value:, value_before:, value_after:)
          )
        end
      end
    end
  end
end
