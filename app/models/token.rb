# frozen_string_literal: true

class Token < ApplicationRecord
  attr_accessor :apparatus_index

  attribute :variants, TokenVariant.to_array_type
  attribute :grouped_variants, TokenGroupedVariant.to_array_type

  validates :index, :variants, presence: true

  belongs_to :project
  delegate :default_witness, to: :project, prefix: true

  default_scope { order(index: :asc) }
  scope :for_project, ->(project) { where(project:) }
  scope :for_apparatus, -> { where('grouped_variants @> ?', '[{"selected": true}]') }

  delegate :t, to: :current_variant, allow_nil: true

  def current_variant
    selected_variant || default_variant
  end

  def default_variant
    variants.find { |variant| variant.for_witness?(project_default_witness) }
  end

  def selected_variant
    grouped_variants.find(&:selected?)
  end

  def secondary_variants
    grouped_variants.select(&:secondary?)
  end

  def apparatus?
    selected_variant.present?
  end
end
