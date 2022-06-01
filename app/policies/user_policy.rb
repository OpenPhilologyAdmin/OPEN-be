# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user.present? && user.approved_admin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
