# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def index?
    approved_admin?
  end

  def destroy?
    approved_admin? && record.user_id == user.id
  end
end
