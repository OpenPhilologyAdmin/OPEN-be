# frozen_string_literal: true

module TokensResizer
  class TokensUpdater
    def initialize(project:, selected_tokens:, new_tokens:)
      @project         = project
      @selected_tokens = selected_tokens
      @new_tokens      = new_tokens
    end

    def self.perform(project:, selected_tokens:, new_tokens:)
      new(project:, selected_tokens:, new_tokens:).perform
    end

    def perform
      starting_token_index  = selected_tokens.first.index
      prev_last_token_index = selected_tokens.last.index

      remove_selected_tokens
      index_new_tokens(index: starting_token_index)
      reindex_old_tokens(prev_index: prev_last_token_index)
      save_new_tokens
    end

    private

    attr_reader :selected_tokens, :new_tokens, :project

    delegate :tokens, to: :project, prefix: true

    def index_new_tokens(index:)
      new_tokens.each do |token|
        token.index = index
        index += 1
      end
    end

    def remove_selected_tokens
      project_tokens.where(id: selected_tokens.pluck(:id)).destroy_all
    end

    def index_assigment_and_value(prev_index:, new_index:)
      if prev_index > new_index
        value     = prev_index - new_index
        operation = '-'
      else
        value     = new_index - prev_index
        operation = '+'
      end
      ["index = index #{operation} ?", value]
    end

    def reindex_old_tokens(prev_index:)
      new_index = new_tokens.last.index

      return if prev_index == new_index

      # rubocop:disable Rails/SkipsModelValidations
      project_tokens.where('index > ?', prev_index)
                    .update_all(
                      index_assigment_and_value(prev_index:, new_index:)
                    )
      # rubocop:enable Rails/SkipsModelValidations
    end

    def save_new_tokens
      new_tokens.each(&:save)
    end
  end
end
