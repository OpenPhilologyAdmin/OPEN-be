# frozen_string_literal: true

module TokensManager
  class Splitter
    class Params
      include ActiveModel::Model

      attr_reader :project, :new_variants, :source_token

      validates :project,      presence: true
      validates :new_variants, presence: true
      validates :source_token, presence: true

      validate :validate_new_variants

      SPLITTER_PHRASE = '{scissors}'

      def initialize(project:, new_variants:, source_token:)
        @project      = project
        @new_variants = new_variants
        @source_token = source_token
      end

      private

      def validate_new_variants
        return errors.add(:new_variants, :blank) if new_variants.blank?

        new_variants.each do |variant|
          return errors.add(:new_variants, :splitter_phrase_missing) if variant[:t].exclude?(SPLITTER_PHRASE)
          return errors.add(:new_variants, :invalid_variant_text)    if source_token_ts.exclude?(plain_t(variant[:t]))
        end
      end

      def source_token_ts
        @source_token_ts ||= source_token.variants.pluck(:t)
      end

      def plain_t(new_variant_t)
        new_variant_t.split(SPLITTER_PHRASE).join
      end
    end
  end
end
