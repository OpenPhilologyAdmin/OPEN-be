# frozen_string_literal: true

class TokenEditorialRemarkPolicy < ApplicationPolicy
  def index?
    approved_admin?
  end
end
