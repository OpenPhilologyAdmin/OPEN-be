# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def index?
    approved_admin?
  end
end
