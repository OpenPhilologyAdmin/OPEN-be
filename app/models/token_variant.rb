# frozen_string_literal: true

class TokenVariant
  include StoreModel::Model
  include FormattableT

  attribute :witness, :string
  attribute :t, :string

  validates :witness,
            inclusion: {
              in: ->(variant) { variant.project_witnesses_ids }
            },
            if:        -> { parent.present? }

  delegate :project_witnesses_ids, to: :parent, prefix: false

  def for_witness?(siglum)
    witness == siglum
  end
end
