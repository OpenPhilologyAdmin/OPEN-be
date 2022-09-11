# frozen_string_literal: true

module TokensManager
  class Resizer
    module Builders
      class TokenSurroundedBySubstrings
        include TokensManager::Resizer::Builders::Concerns::WithoutPlaceholders
        include TokensManager::Resizer::Builders::Concerns::WithSurroundingSubstrings

        def initialize(token:, selected_text:)
          @token = token
          @substring_before, @substring_after = substrings_surrounding_token(selected_text)
        end

        def self.perform(token:, selected_text:)
          new(token:, selected_text:).perform
        end

        def perform
          process_values
          token
        end

        private

        attr_reader :token, :substring_before, :substring_after

        def substrings_surrounding_token(selected_text)
          TokensManager::Resizer::Builders::SubstringsSurroundingValue.perform(
            base_string: selected_text,
            value:       token.t
          )
        end

        def resources_to_process
          @resources_to_process = [token.variants, token.editorial_remark, token.grouped_variants].flatten.compact
        end

        def process_values
          resources_to_process.each do |resource|
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
