# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def index?
    approved_admin?
  end

  def update?
    approved_admin? && record.user_id == user.id
  end

  def destroy?
    approved_admin? && record.user_id == user.id
  end

  def permitted_attributes_for_update
    %i[body]
  end
end
