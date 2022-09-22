# frozen_string_literal: true

module TokensManager
  class Resizer
    def initialize(project:, user:, selected_text:, selected_token_ids:, tokens_with_offsets:)
      @project         = project
      @user            = user
      @selected_text   = selected_text
      @selected_tokens = project.tokens.where(id: selected_token_ids)
      @tokens_with_offsets = tokens_with_offsets
    end

    def self.perform(project:, user:, selected_text:, selected_token_ids:, tokens_with_offsets:)
      new(project:, user:, selected_text:, selected_token_ids:, tokens_with_offsets:).perform
    end

    def perform
      update_tokens
      update_last_editor
    end

    private

    attr_reader :project, :user, :selected_text, :selected_tokens, :tokens_with_offsets

    def update_tokens
      prepared_tokens = Resizer::Preparer.perform(selected_text:, selected_tokens:, project:, tokens_with_offsets:)
      Resizer::Processor.perform(project:, selected_tokens:, prepared_tokens:)
    end

    def update_last_editor
      project.update(last_editor: user)
    end
  end
end
