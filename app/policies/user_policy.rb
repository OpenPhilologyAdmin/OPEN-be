# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user.present? && user.admin?
  end
end
