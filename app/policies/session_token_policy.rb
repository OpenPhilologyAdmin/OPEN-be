# frozen_string_literal: true

class SessionTokenPolicy < ApplicationPolicy
  def initialize(user, _record)
    @user = user
    super
  end

  def new?
    false
  end

  def create?
    approved_admin?
  end
end
