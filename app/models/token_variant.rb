# frozen_string_literal: true

class TokenVariant
  include StoreModel::Model
  include FormattableT

  attribute :witness, :string
  attribute :t, :string

  def for_witness?(siglum)
    witness == siglum
  end
end
