# frozen_string_literal: true

class SessionTokenPolicy < ApplicationPolicy
  def initialize(user, _record)
    @user = user
    super
  end

  def create?
    approved_admin?
  end
end
