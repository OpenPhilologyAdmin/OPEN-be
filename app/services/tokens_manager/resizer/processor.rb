# frozen_string_literal: true

module TokensManager
  class Resizer
    class Processor
      def initialize(project:, selected_tokens:, prepared_tokens:)
        @project         = project
        @selected_tokens = selected_tokens
        @prepared_tokens = prepared_tokens
      end

      def self.perform(project:, selected_tokens:, prepared_tokens:)
        new(project:, selected_tokens:, prepared_tokens:).perform
      end

      def perform
        remove_selected_tokens
        assign_index_to_prepared_tokens
        shift_following_tokens
        save_prepared_tokens
      end

      private

      attr_reader :selected_tokens, :prepared_tokens, :project

      def remove_selected_tokens
        TokensManager::Resizer::Processors::TokensRemover.perform(
          project:,
          tokens_to_remove: selected_tokens
        )
      end

      def assign_index_to_prepared_tokens
        TokensManager::Resizer::Processors::PreparedTokensIndexer.perform(
          starting_index:  selected_tokens.first.index,
          prepared_tokens:
        )
      end

      def shift_following_tokens
        TokensManager::Resizer::Processors::FollowingTokensMover.perform(
          project:,
          new_last_index:      prepared_tokens.last.index,
          previous_last_index: selected_tokens.last.index
        )
      end

      def save_prepared_tokens
        prepared_tokens.each(&:save)
      end
    end
  end
end
