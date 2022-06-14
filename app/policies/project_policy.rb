# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def create?
    approved_admin?
  end

  def new?
    false
  end

  def permitted_attributes_for_create
    %i[
      name
      source_file
    ]
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
