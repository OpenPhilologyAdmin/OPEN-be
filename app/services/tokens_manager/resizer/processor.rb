# frozen_string_literal: true

module TokensManager
  class Resizer
    class Processor
      def initialize(project:, selected_tokens:, new_tokens:)
        @project         = project
        @selected_tokens = selected_tokens
        @new_tokens      = new_tokens
        @starting_token_index = @selected_tokens.first.index
        @previous_last_token_index = @selected_tokens.last.index
      end

      def self.perform(project:, selected_tokens:, new_tokens:)
        new(project:, selected_tokens:, new_tokens:).perform
      end

      def perform
        remove_selected_tokens
        index_new_tokens
        reindex_old_tokens
        save_new_tokens
      end

      private

      attr_reader :selected_tokens, :new_tokens, :project,
                  :starting_token_index, :previous_last_token_index

      delegate :tokens, to: :project, prefix: true

      def index_new_tokens
        index = starting_token_index
        new_tokens.each do |token|
          token.index = index
          index += 1
        end
      end

      def remove_selected_tokens
        project_tokens.where(id: selected_tokens.pluck(:id)).destroy_all
      end

      def index_assigment_formula(new_index:)
        if previous_last_token_index > new_index
          value     = previous_last_token_index - new_index
          operation = '-'
        else
          value     = new_index - previous_last_token_index
          operation = '+'
        end
        ["index = index #{operation} ?", value]
      end

      def reindex_old_tokens
        new_index = new_tokens.last.index

        return if previous_last_token_index == new_index

        # rubocop:disable Rails/SkipsModelValidations
        project_tokens.where('index > ?', previous_last_token_index)
                      .update_all(index_assigment_formula(new_index:))
        # rubocop:enable Rails/SkipsModelValidations
      end

      def save_new_tokens
        new_tokens.each(&:save)
      end
    end
  end
end
