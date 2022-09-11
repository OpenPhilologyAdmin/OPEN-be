# frozen_string_literal: true

module TokensManager
  class Resizer
    module Builders
      class TokenFromValue
        include TokensManager::Resizer::Builders::Concerns::WithoutPlaceholders

        def initialize(value:, project:)
          @value   = without_placeholders(value)
          @project = project
          @token   = Token.new(project:)
        end

        def self.perform(value:, project:)
          new(value:, project:).perform
        end

        def perform
          token.variants         = variants
          token.grouped_variants = grouped_variants
          token.editorial_remark = editorial_remark
          token
        end

        private

        attr_reader :value, :project, :token

        delegate :witnesses_ids, to: :project, prefix: true

        def variants
          @variants ||= project_witnesses_ids.map do |witness|
            TokenVariant.new(t: value, witness:)
          end
        end

        def editorial_remark
          nil
        end

        def grouped_variants
          GroupedVariantsGenerator.perform(token:)
        end
      end
    end
  end
end
