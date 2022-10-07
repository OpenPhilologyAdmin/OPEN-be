# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      class ValueBeforeAndAfterAdder
        include TokensManager::Resizer::Preparers::Concerns::WithoutPlaceholders
        include TokensManager::Resizer::Preparers::Concerns::WithBeforeAndAfterValues

        def initialize(token:, value_before:, value_after:)
          @token = token
          @value_before = value_before
          @value_after = value_after
        end

        def self.perform(token:, value_before:, value_after:)
          new(token:, value_before:, value_after:).perform
        end

        def perform
          process_values_of(variants)
          process_values_of(grouped_variants)
          process_value_of(editorial_remark) if editorial_remark
          token
        end

        private

        attr_reader :token, :value_before, :value_after

        delegate :variants, :grouped_variants, :editorial_remark, to: :token

        def process_values_of(resources)
          resources.each do |resource|
            process_value_of(resource)
          end
        end

        def process_value_of(resource)
          value = with_before_and_after_values(
            value:        resource.t,
            value_before:,
            value_after:
          )
          resource.t = without_placeholders(value:)
        end
      end
    end
  end
end
