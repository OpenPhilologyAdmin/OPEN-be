# frozen_string_literal: true

module TokensManager
  class Splitter
    class Params
      include ActiveModel::Model

      attr_reader :project, :new_variants

      validates :project, presence: true

      def initialize(project:, new_variants:)
        @project = project
        @new_variants = new_variants
      end

      private

      def validate_new_variants
        # TO DO: If any variant of new variants doesn't include :scissors: throw an error

        # return error.add(:new_variants, :unprocessable_entity)
      end
    end
  end
end
