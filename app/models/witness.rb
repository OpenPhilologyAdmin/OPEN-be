# frozen_string_literal: true

class Witness
  include StoreModel::Model

  attribute :siglum, :string
  attribute :name, :string
  attribute :default, :boolean, default: false
end
