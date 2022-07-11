# frozen_string_literal: true

class TokenGroupedVariant
  include StoreModel::Model

  attribute :witnesses, :array_of_strings, default: -> { [] }
  attribute :t, :string
  attribute :selected, :boolean, default: false
  attribute :possible, :boolean, default: false

  def for_witness?(siglum)
    witnesses.include?(siglum)
  end
end
