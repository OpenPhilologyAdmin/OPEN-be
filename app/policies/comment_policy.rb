# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def index?
    approved_admin?
  end

  def create?
    approved_admin?
  end

  def permitted_attributes_for_create
    %i[body]
  end
end
