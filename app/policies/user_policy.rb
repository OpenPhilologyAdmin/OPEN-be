# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    approved_admin?
  end

  def approve?
    approved_admin?
  end

  def new?
    false
  end

  def create?
    user.blank?
  end

  def permitted_attributes_for_create
    %i[
      name
      email
      password
      password_confirmation
    ]
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end