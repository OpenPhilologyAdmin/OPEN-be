# frozen_string_literal: true

class TokenVariant
  include StoreModel::Model

  attribute :witness, :string
  attribute :t, :string
  attribute :selected, :boolean, default: false
  attribute :deleted, :boolean, default: false
end
