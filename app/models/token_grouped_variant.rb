# frozen_string_literal: true

class TokenGroupedVariant
  include StoreModel::Model
  include FormattableT

  attribute :witnesses, :array_of_strings, default: -> { [] }
  attribute :t, :string
  attribute :selected, :boolean, default: false
  attribute :possible, :boolean, default: false

  def for_witness?(siglum)
    witnesses.include?(siglum)
  end

  def secondary?
    possible? && !selected?
  end

  def insignificant?
    !(possible? || selected?)
  end
end
