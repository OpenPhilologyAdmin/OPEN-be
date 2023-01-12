# frozen_string_literal: true

module TokensManager
  class Splitter
    class Processor
      SPLITTER_PHRASE = ':scissors:'

      def initialize(project:, source_token:, new_variants:)
        @project        = project
        @source_token   = source_token
        @new_variants   = new_variants
      end

      def self.perform(project:, source_token:, new_variants:)
        new(project:, source_token:, new_variants:).perform
      end

      def perform
        initialize_split_tokens(prepare_split_variants)
        shift_following_tokens
        generate_grouped_variants
        delete_source_token
        save_new_tokens
      end

      attr_reader :project, :source_token, :new_variants, :token_one, :token_two

      private

      def prepare_split_variants
        new_variants_hash = { 1 => [], 2 => [] }

        new_variants.each do |variant|
          split_t = variant[:t].split(SPLITTER_PHRASE)

          (1..2).each do |i|
            new_variants_hash[i] <<
              TokenVariant.new(
                witness: variant[:witness],
                t:       split_t[i - 1]
              )
          end
        end

        new_variants_hash
      end

      def initialize_split_tokens(new_variants_hash)
        @token_one = Token.new(project:, index: source_token.index, variants: new_variants_hash[1])
        @token_two = Token.new(project:, index: source_token.index + 1, variants: new_variants_hash[2])
      end

      def generate_grouped_variants
        token_one.grouped_variants = GroupedVariantsGenerator.perform(token: token_one)
        token_two.grouped_variants = GroupedVariantsGenerator.perform(token: token_two)
      end

      def shift_following_tokens
        TokensManager::Resizer::Processors::FollowingTokensMover.perform(
          project:,
          new_last_index:      token_two.index,
          previous_last_index: token_one.index
        )
      end

      def delete_source_token
        source_token.update(deleted: true)
      end

      def save_new_tokens
        token_one.save
        token_two.save
      end
    end
  end
end
