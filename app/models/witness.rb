# frozen_string_literal: true

class Witness
  include StoreModel::Model

  attribute :siglum, :string
  attribute :name, :string
  alias id siglum

  validates :siglum, presence: true
  validates :name, length: { maximum: 50, allow_blank: true }

  # overwrite as_json from StoreModel::Model to include also the :id
  def as_json(options = {})
    additional_attributes = { id:, default: default? }
    attributes.with_indifferent_access.merge(additional_attributes).as_json(options)
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

  def handle_default!(value)
    value ? default! : not_default!
  end
end
