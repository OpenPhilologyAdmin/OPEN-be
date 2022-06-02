# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user&.approved_admin?
  end

  def approve?
    user&.approved_admin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
