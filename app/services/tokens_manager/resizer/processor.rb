# frozen_string_literal: true

module TokensManager
  class Resizer
    class Processor
      def initialize(project:, selected_tokens:, new_tokens:)
        @project         = project
        @selected_tokens = selected_tokens
        @new_tokens      = new_tokens
      end

      def self.perform(project:, selected_tokens:, new_tokens:)
        new(project:, selected_tokens:, new_tokens:).perform
      end

      def perform
        remove_redundant_tokens
        assign_index_to_new_tokens
        shift_following_tokens
        save_new_tokens
      end

      private

      attr_reader :selected_tokens, :new_tokens, :project

      def remove_redundant_tokens
        TokensManager::Resizer::Processors::RedundantTokensRemover.perform(
          project:,
          tokens_to_remove: selected_tokens,
          relevant_tokens:  new_tokens
        )
      end

      def assign_index_to_new_tokens
        TokensManager::Resizer::Processors::NewTokensIndexer.perform(
          starting_index: selected_tokens.first.index,
          new_tokens:
        )
      end

      def shift_following_tokens
        TokensManager::Resizer::Processors::FollowingTokensMover.perform(
          project:,
          new_last_index:      new_tokens.last.index,
          previous_last_index: selected_tokens.last.index
        )
      end

      def save_new_tokens
        new_tokens.each(&:save)
      end
    end
  end
end
