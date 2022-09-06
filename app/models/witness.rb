# frozen_string_literal: true

class Witness
  include StoreModel::Model

  attribute :siglum, :string
  attribute :name, :string
  alias id siglum

  validates :siglum, presence: true
  validates :name, length: { maximum: 50, allow_blank: true }
  validate :validate_uniqueness_of_siglum

  delegate :witnesses_ids, to: :parent, prefix: true, allow_nil: true

  # overwrite as_json from StoreModel::Model to include also the :id
  def as_json(options = {})
    additional_attributes = { id:, default: default? }
    attributes.with_indifferent_access.merge(additional_attributes).as_json(options)
  end

  def validate_uniqueness_of_siglum
    return if parent_witnesses_ids.blank?

    matching_witnesses_number = parent_witnesses_ids.select { |witness_siglum| witness_siglum.casecmp?(siglum) }.size
    return if matching_witnesses_number < 2

    errors.add(:siglum, I18n.t('errors.messages.taken'))
  end

  def default?
    parent.default_witness == siglum
  end

  def default!
    parent.default_witness = siglum
  end

  def not_default!
    return unless default?

    parent.default_witness = nil
  end

  def assign_default(value)
    value ? default! : not_default!
  end
end
