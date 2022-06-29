# frozen_string_literal: true

class TokenGroupedVariant
  include StoreModel::Model

  attribute :witnesses, :array_of_strings, default: -> { [] }
  attribute :t, :string
  attribute :selected, :boolean, default: false
end
