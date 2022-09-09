# frozen_string_literal: true

module TokensManager
  class Resizer
    def initialize(project:, user:, selected_text:, selected_token_ids:)
      @project         = project
      @user            = user
      @selected_text   = selected_text
      @selected_tokens = project.tokens.where(id: selected_token_ids)
    end

    def self.perform(project:, user:, selected_text:, selected_token_ids:)
      new(project:, user:, selected_text:, selected_token_ids:).perform
    end

    def perform
      update_tokens
      update_last_editor
    end

    private

    attr_reader :project, :user, :selected_text, :selected_tokens

    def update_tokens
      new_tokens = Resizer::Builder.perform(selected_text:, selected_tokens:, project:)
      Resizer::Processor.perform(project:, selected_tokens:, new_tokens:)
    end

    def update_last_editor
      project.update(last_editor: user)
    end
  end
end
