# frozen_string_literal: true

class TokenGroupedVariant
  include StoreModel::Model
  include FormattableT
  WITNESSES_SEPARATOR = ' '

  attribute :id, :string
  attribute :witnesses, :array_of_strings, default: -> { [] }
  attribute :t, :string
  attribute :selected, :boolean, default: false
  attribute :possible, :boolean, default: false

  # always auto-calculate the id from the witnesses
  def initialize(attributes = {})
    super
    self.id = witnesses.sort.join
  end

  def for_witness?(siglum)
    witnesses.include?(siglum)
  end

  def significant?
    possible? || selected?
  end

  def secondary?
    possible? && !selected?
  end

  def insignificant?
    !significant?
  end

  def formatted_witnesses
    witnesses.join(WITNESSES_SEPARATOR)
  end
end
