# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def create?
    approved_admin?
  end

  def new?
    false
  end

  def show?
    approved_admin?
  end

  def permitted_attributes_for_create
    %i[
      name
      source_file: [data filename content_type identify]
    ]
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
