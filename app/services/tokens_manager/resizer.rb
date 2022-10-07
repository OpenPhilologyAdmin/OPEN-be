# frozen_string_literal: true

module TokensManager
  class Resizer
    def initialize(project:, user:, selected_text:, selected_token_ids:, tokens_with_offsets:)
      @params = Params.new(project:, selected_text:, selected_token_ids:, tokens_with_offsets:)
      @user   = user
    end

    def self.perform(project:, user:, selected_text:, selected_token_ids:, tokens_with_offsets:)
      new(project:, user:, selected_text:, selected_token_ids:, tokens_with_offsets:).perform
    end

    def perform
      update_tokens
      update_last_editor
    end

    private

    attr_reader :params, :user

    delegate :project, :selected_tokens, to: :params

    def update_tokens
      prepared_tokens = Preparer.perform(params:)
      Processor.perform(project:, selected_tokens:, prepared_tokens:)
    end

    def update_last_editor
      project.update(last_editor: user)
    end
  end
end
