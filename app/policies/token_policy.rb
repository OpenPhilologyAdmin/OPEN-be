# frozen_string_literal: true

class TokenPolicy < ApplicationPolicy
  def index?
    approved_admin?
  end

  def show?
    approved_admin?
  end

  def update?
    approved_admin?
  end

  def significant_variants?
    index?
  end

  def insignificant_variants?
    index?
  end

  def permitted_attributes_for_update
    [
      grouped_variants: [:t, :selected, :possible, { witnesses: [] }],
      variants:         %i[t witness]
    ]
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
