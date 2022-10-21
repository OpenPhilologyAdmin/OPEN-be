# frozen_string_literal: true

module TokensManager
  class Resizer
    class Params
      include ActiveModel::Model
      ZERO_OR_POSITIVE_INTEGER_REGEX = /\A\d+\z/

      attr_reader :project, :selected_text, :tokens_with_offsets

      validates :project, :selected_text, presence: true
      validate :validates_selected_text, unless: -> { selected_text.blank? }
      validate :validate_selected_token_ids
      validate :validates_tokens_with_offsets

      def initialize(project:, selected_text:, selected_token_ids:, tokens_with_offsets:)
        @project = project
        @selected_token_ids = selected_token_ids
        @selected_text       = selected_text
        @tokens_with_offsets = tokens_with_offsets
      end

      def selected_tokens
        @selected_tokens ||= project.present? ? project_tokens.where(id: selected_token_ids) : []
      end

      def selected_multiple_readings_token
        @selected_multiple_readings_token ||= selected_multiple_readings_tokens.first
      end

      private

      attr_reader :selected_token_ids

      delegate :tokens, to: :project, prefix: true, allow_nil: true

      def full_text_of_selected_tokens
        @full_text_of_selected_tokens ||= selected_tokens.map(&:t).join
      end

      def selected_multiple_readings_tokens
        @selected_multiple_readings_tokens ||= selected_tokens.reject(&:one_grouped_variant?)
      end

      def multiple_readings_token_offsets
        @multiple_readings_token_offsets ||= tokens_with_offsets.select do |token_with_offset|
          token_with_offset[:token_id] == selected_multiple_readings_token.id
        end
      end

      def validates_selected_text
        return if selected_tokens.blank?
        return if full_text_of_selected_tokens.include?(selected_text)

        errors.add(:selected_text, :does_not_match_full_text_of_selected_tokens)
      end

      def validate_selected_token_ids
        return errors.add(:selected_token_ids, :blank) if selected_token_ids.blank?
        return errors.add(:selected_token_ids, :tokens_not_found) if selected_tokens.empty?

        validate_selected_multiple_readings_tokens_number
        validate_selected_tokens_order
      end

      def validate_selected_multiple_readings_tokens_number
        return if selected_multiple_readings_tokens.size < 2

        errors.add(:selected_token_ids, :more_than_one_multiple_readings_token)
      end

      def validate_selected_tokens_order
        starting_token_index = selected_tokens.first.index
        selected_tokens.each_with_index do |selected_token, index|
          next if selected_token.index == index + starting_token_index

          errors.add(:selected_token_ids, :tokens_not_in_order)
          break
        end
      end

      def validates_tokens_with_offsets
        return errors.add(:tokens_with_offsets, :blank) if tokens_with_offsets.blank?

        validates_offsets_of_tokens_with_offsets
        validates_token_ids_of_tokens_with_offsets
        validate_offsets_of_selected_multiple_readings_token
      end

      def validates_offsets_of_tokens_with_offsets
        offsets = tokens_with_offsets.pluck(:offset)

        return if offsets.all? { |offset| offset.to_s.match?(ZERO_OR_POSITIVE_INTEGER_REGEX) }

        errors.add(:tokens_with_offsets, :invalid_offsets)
      end

      def validates_token_ids_of_tokens_with_offsets
        return if selected_token_ids.blank?

        offset_token_ids = tokens_with_offsets.pluck(:token_id)

        return if (offset_token_ids - selected_token_ids).empty?

        errors.add(:tokens_with_offsets, :invalid_token_ids)
      end

      def validate_offsets_of_selected_multiple_readings_token
        return unless multiple_readings_token_offset_given?

        return if multiple_readings_token_offsets_valid?

        errors.add(:tokens_with_offsets, :multiple_readings_token_cannot_be_divided)
      end

      def multiple_readings_token_offset_given?
        return false if selected_multiple_readings_token.nil?

        multiple_readings_token_offsets.any?
      end

      def multiple_readings_token_offsets_valid?
        start_of_token_offset = 0
        end_of_token_offset = selected_multiple_readings_token.t.size
        allowed_offsets = [start_of_token_offset, end_of_token_offset]
        multiple_readings_token_offsets.all? do |token_with_offset|
          allowed_offsets.include?(token_with_offset[:offset])
        end
      end
    end
  end
end
