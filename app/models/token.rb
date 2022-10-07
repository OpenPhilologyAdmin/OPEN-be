# frozen_string_literal: true

class Token < ApplicationRecord
  attr_accessor :apparatus_index

  attribute :variants, TokenVariant.to_array_type
  attribute :grouped_variants, TokenGroupedVariant.to_array_type
  attribute :editorial_remark, TokenEditorialRemark.to_type

  validates :index, :variants, :grouped_variants, presence: true
  validate :validate_selected_grouped_variant

  validates :editorial_remark, store_model: { merge_errors: true }, allow_nil: true
  validates :variants, store_model: { merge_array_errors: true }

  belongs_to :project

  has_many :comments, dependent: :destroy

  delegate :witnesses_ids, to: :project, prefix: true
  delegate :default_witness, to: :project, prefix: true
  delegate :witness, to: :editorial_remark, allow_nil: true, prefix: true

  default_scope { where(deleted: false).order(index: :asc) }
  scope :for_project, ->(project) { where(project:) }
  scope :for_apparatus, -> { where('grouped_variants @> ?', '[{"selected": true}]') }
  scope :with_index_higher_than, ->(index) { where('index > ?', index) }

  def validate_selected_grouped_variant
    return if grouped_variants.blank?
    return if grouped_variants.select(&:selected?).size <= 1

    errors.add(:grouped_variants, :more_than_one_selected)
  end

  # use the :formatted_t value, so the token is correctly displayed in the editor
  def t
    current_variant.formatted_t
  end

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

  def apparatus
    Apparatus::SignificantEntry.new(token: self).value
  end
end
