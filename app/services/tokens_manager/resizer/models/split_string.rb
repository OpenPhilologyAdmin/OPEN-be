# frozen_string_literal: true

module TokensManager
  class Resizer
    module Models
      class SplitString
        def initialize(base_string:, substring:)
          @base_string = base_string
          @substring = substring
        end

        def substring_before
          @substring_before ||= base_string[0...substring_index]
        end

        def substring_after
          @substring_after ||= base_string[(substring_index + substring.length)...]
        end

        private

        attr_reader :base_string, :substring

        def substring_index
          @substring_index ||= base_string.index(substring)
        end
      end
    end
  end
end
