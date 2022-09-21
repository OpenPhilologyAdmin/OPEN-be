# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      class BeforeAndAfterSelectionValues
        def initialize(tokens:, tokens_with_offsets:)
          @tokens_values_with_offsets = TokenValuesWithOffsets.perform(tokens:, tokens_with_offsets:)
        end

        def before_selection_value
          before_selection.before_offset_value
        end

        def after_selection_value
          after_selection.after_offset_value
        end

        private

        attr_reader :tokens_values_with_offsets, :sort_param

        def before_selection
          @before_selection ||= tokens_values_with_offsets.first
        end

        def after_selection
          @after_selection ||= tokens_values_with_offsets.last
        end
      end
    end
  end
end
