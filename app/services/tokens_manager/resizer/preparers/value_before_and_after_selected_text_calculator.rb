# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      class ValueBeforeAndAfterSelectedTextCalculator
        def initialize(tokens:, tokens_with_offsets:)
          @tokens_values_with_offsets = TokenValuesWithOffsetsGenerator.perform(tokens:, tokens_with_offsets:)
        end

        delegate :value_before, to: :before_selected_text

        delegate :value_after, to: :after_selected_text

        private

        attr_reader :tokens_values_with_offsets, :sort_param

        def before_selected_text
          @before_selected_text ||= tokens_values_with_offsets.first
        end

        def after_selected_text
          @after_selected_text ||= tokens_values_with_offsets.last
        end
      end
    end
  end
end
