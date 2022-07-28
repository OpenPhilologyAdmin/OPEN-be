# frozen_string_literal: true

class Token < ApplicationRecord
  attr_accessor :apparatus_index

  attribute :variants, TokenVariant.to_array_type
  attribute :grouped_variants, TokenGroupedVariant.to_array_type

  validates :index, :variants, presence: true

  belongs_to :project
  delegate :default_witness, to: :project, prefix: true
  delegate :t, to: :current_variant, allow_nil: true

  default_scope { order(index: :asc) }
  scope :for_project, ->(project) { where(project:) }
  scope :for_apparatus, -> { where('grouped_variants @> ?', '[{"selected": true}]') }
  scope :with_insignificant_variants, -> { where('grouped_variants @> ?', '[{"selected": false, "possible": false}]') }

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

  def insignificant_variants
    grouped_variants.select(&:insignificant?)
  end

  def evaluated?
    selected_variant.present?
  end

  alias apparatus? evaluated?

  def one_grouped_variant?
    grouped_variants.size == 1
  end

  def state
    return :one_variant if one_grouped_variant?
    return :not_evaluated unless evaluated?

    if secondary_variants.any?
      :evaluated_with_multiple
    else
      :evaluated_with_single
    end
  end
end
