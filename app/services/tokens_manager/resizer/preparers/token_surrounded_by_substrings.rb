# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      class TokenSurroundedBySubstrings
        include TokensManager::Resizer::Preparers::Concerns::WithoutPlaceholders
        include TokensManager::Resizer::Preparers::Concerns::WithSurroundingSubstrings

        def initialize(token:, selected_text:)
          @token = token
          @substring_before, @substring_after = substrings_surrounding_token(selected_text)
        end

        def self.perform(token:, selected_text:)
          new(token:, selected_text:).perform
        end

        def perform
          add_substrings_to_token_readings
          token
        end

        private

        attr_reader :token, :substring_before, :substring_after

        def substrings_surrounding_token(selected_text)
          TokensManager::Resizer::Preparer::SubstringsSurroundingValue.perform(
            base_string: selected_text,
            value:       token.t
          )
        end

        # all attributes that have :t
        def token_readings
          @token_readings = [
            token.variants, token.editorial_remark, token.grouped_variants
          ].flatten.compact
        end

        def add_substrings_to_token_readings
          token_readings.each do |resource|
            resource.t = processed_value(resource.t)
          end
        end

        def processed_value(value)
          without_placeholders(
            with_surrounding_substrings(value:, substring_before:, substring_after:)
          )
        end
      end
    end
  end
end
