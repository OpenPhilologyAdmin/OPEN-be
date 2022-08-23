# frozen_string_literal: true

class TokenEditorialRemark
  include StoreModel::Model

  EDITORIAL_REMARK_TYPES = {
    'Standardisation' => 'st.',
    'Correction'      => 'corr.',
    'Emendation'      => 'em.',
    'Conjecture'      => 'conj.'
  }.freeze

  attribute :type, :string
  attribute :t, :string

  alias witness type
  validates :type, inclusion: EDITORIAL_REMARK_TYPES.values
end
