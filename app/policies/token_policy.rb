# frozen_string_literal: true

class TokenPolicy < ApplicationPolicy
  def index?
    approved_admin?
  end

  def show?
    approved_admin?
  end

  def update_variants?
    approved_admin?
  end

  def update_grouped_variants?
    approved_admin?
  end

  def resize?
    approved_admin?
  end

  def edited?
    approved_admin?
  end

  def significant_variants?
    index?
  end

  def insignificant_variants?
    index?
  end

  def permitted_attributes_for_update_variants
    [
      variants:         %i[t witness],
      editorial_remark: %i[t type]
    ]
  end

  def permitted_attributes_for_update_grouped_variants
    [
      grouped_variants: %i[id selected possible]
    ]
  end

  def permitted_attributes_for_resize
    [
      {
        selected_token_ids: []
      }
    ]
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
