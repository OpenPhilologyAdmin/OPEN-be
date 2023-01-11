# frozen_string_literal: true

module TokensManager
  class Splitter
    class Params
      include ActiveModel::Model

      attr_reader :project, :token_id

      validates :project, presence: true
      validate :validate_token_id

      def initialize(project:, token_id:)
        @project = project
        @token_id = token_id
      end

      def source_token
        @source_token ||= project.present? ? project_tokens.find_by(id: token_id) : nil
      end

      private

      delegate :tokens, to: :project, prefix: true, allow_nil: true

      def validate_token_id
        return errors.add(:token_id, :blank) if token_id.blank?

        source_token
      end
    end
  end
end
