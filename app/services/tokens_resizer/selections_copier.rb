# frozen_string_literal: true

module TokensResizer
  class SelectionsCopier
    def initialize(target_token:, source_token:)
      @target_token = target_token
      @source_token = source_token
    end

    def self.perform(target_token:, source_token:)
      new(target_token:, source_token:).perform
    end

    def perform
      source_grouped_variants.each do |source_grouped_variant|
        target_grouped_variant          = find_target_grouped_variant_for(witnesses: source_grouped_variant.witnesses)
        target_grouped_variant.selected = source_grouped_variant.selected
        target_grouped_variant.possible = source_grouped_variant.possible
      end
    end

    private

    attr_reader :target_token, :source_token

    def source_grouped_variants
      @source_grouped_variants ||= source_token.grouped_variants.select(&:significant?)
    end

    def target_grouped_variants
      @target_grouped_variants ||= target_token.grouped_variants
    end

    def find_target_grouped_variant_for(witnesses:)
      target_grouped_variants.find { |grouped_variant| grouped_variant.witnesses.sort == witnesses.sort }
    end
  end
end
