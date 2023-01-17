# frozen_string_literal: true

module TokensManager
  class Resizer
    class Params
      include ActiveModel::Model
      ZERO_OR_POSITIVE_INTEGER_REGEX = /\A\d+\z/

      attr_reader :project

      validates :project, presence: true
      validate :validate_selected_token_ids

      def initialize(project:, selected_token_ids:)
        @project = project
        @selected_token_ids = selected_token_ids
      end

      def selected_tokens
        @selected_tokens ||= project.present? ? project_tokens.where(id: selected_token_ids) : []
      end

      private

      attr_reader :selected_token_ids

      delegate :tokens, to: :project, prefix: true, allow_nil: true

      def validate_selected_token_ids
        return errors.add(:selected_token_ids, :blank) if selected_token_ids.blank?
        return errors.add(:selected_token_ids, :tokens_not_found) if selected_tokens.empty?

        validate_selected_tokens_order
      end

      def validate_selected_tokens_order
        starting_token_index = selected_tokens.first.index
        selected_tokens.each_with_index do |selected_token, index|
          next if selected_token.index == index + starting_token_index

          errors.add(:selected_token_ids, :tokens_not_in_order)
          break
        end
      end
    end
  end
end
