# frozen_string_literal: true

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
          return if previous_last_index == new_last_index

          following_tokens.update_all(index_shift_formula) # rubocop:disable Rails/SkipsModelValidations
        end

        private

        attr_reader :project, :previous_last_index, :new_last_index

        delegate :tokens, to: :project, prefix: true

        def following_tokens
          @following_tokens ||= project_tokens.where('index > ?', previous_last_index)
        end

        def index_shift_formula
          if previous_last_index > new_last_index
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
