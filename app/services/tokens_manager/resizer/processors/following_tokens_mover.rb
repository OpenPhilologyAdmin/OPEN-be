# frozen_string_literal: true

# The service should be used when the tokens are removed or added to the project.
# If you are adding new tokens, please run the service first and then save new tokens.
# The :previous_last_index is the last index for the edited tokens.
# The :new_last_index is the index where the new/edited tokens end.
# Service will calculate if the indexes of tokens follows the updated ones
# should be changed (increased/decreased) and it will update them to the new value.

module TokensManager
  class Resizer
    module Processors
      class FollowingTokensMover
        def initialize(project:, previous_last_index:, new_last_index:)
          @project             = project
          @previous_last_index = previous_last_index
          @new_last_index      = new_last_index
        end

        def self.perform(project:, previous_last_index:, new_last_index:)
          new(project:, previous_last_index:, new_last_index:).perform
        end

        def perform
          return if index_unchanged?

          following_tokens.update_all(index_shift_formula) # rubocop:disable Rails/SkipsModelValidations
        end

        private

        attr_reader :project, :previous_last_index, :new_last_index

        delegate :tokens, to: :project, prefix: true

        def following_tokens
          @following_tokens ||= project_tokens.with_index_higher_than(previous_last_index)
        end

        def index_unchanged?
          previous_last_index == new_last_index
        end

        def index_decreased?
          new_last_index < previous_last_index
        end

        def index_shift_formula
          if index_decreased?
            value     = previous_last_index - new_last_index
            operation = '-'
          else
            value     = new_last_index - previous_last_index
            operation = '+'
          end
          ["index = index #{operation} ?", value]
        end
      end
    end
  end
end
