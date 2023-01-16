# frozen_string_literal: true

module TokensManager
  class Resizer
    class Processor
      def initialize(project:, selected_tokens:, prepared_token:)
        @project         = project
        @selected_tokens = selected_tokens
        @prepared_token = prepared_token
      end

      def self.perform(project:, selected_tokens:, prepared_token:)
        new(project:, selected_tokens:, prepared_token:).perform
      end

      def perform
        remove_selected_tokens
        shift_following_tokens
        prepared_token.save
      end

      private

      attr_reader :selected_tokens, :prepared_token, :project

      def remove_selected_tokens
        TokensManager::Resizer::Processors::TokensRemover.perform(
          project:,
          tokens_to_remove: selected_tokens
        )
      end

      def shift_following_tokens
        TokensManager::Resizer::Processors::FollowingTokensMover.perform(
          project:,
          new_last_index:,
          previous_last_index:
        )
      end

      def new_last_index
        prepared_token.index
      end

      def previous_last_index
        selected_tokens.last.index
      end
    end
  end
end
