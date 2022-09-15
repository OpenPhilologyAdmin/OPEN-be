# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      class SubstringsSurroundingValue
        def initialize(base_string:, value:)
          @base_string = base_string
          @value = value
        end

        def self.perform(base_string:, value:)
          new(base_string:, value:).perform
        end

        def perform
          [substring_before, substring_after]
        end

        private

        attr_reader :base_string, :value

        def value_index
          @value_index ||= base_string.index(value)
        end

        def substring_before
          @substring_before ||= base_string[0...value_index]
        end

        def substring_after
          @substring_after ||= base_string[(value_index + value.length)...]
        end
      end
    end
  end
end
