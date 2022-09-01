# frozen_string_literal: true

class TokenSerializer
  RECORD_ATTRIBUTES = %i[id].freeze
  RECORD_METHODS    = %i[apparatus variants editorial_remark grouped_variants].freeze

  def initialize(record:)
    @record = record
    process_grouped_variants
  end

  def as_json(_options = {})
    record.as_json(
      only:    RECORD_ATTRIBUTES,
      methods: RECORD_METHODS
    )
  end

  private

  attr_reader :record

  def process_grouped_variants
    record.grouped_variants.each do |grouped_variant|
      grouped_variant.t = grouped_variant.formatted_t
    end
  end
end
