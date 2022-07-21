# frozen_string_literal: true

class TokenPolicy < ApplicationPolicy
  def index?
    approved_admin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
