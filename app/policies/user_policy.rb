# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    approved_admin?
  end

  def approve?
    approved_admin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
