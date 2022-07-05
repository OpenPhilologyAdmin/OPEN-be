# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def index?
    approved_admin?
  end

  def create?
    approved_admin?
  end

  def new?
    false
  end

  def show?
    approved_admin?
  end

  def destroy?
    approved_admin? && record.creator == user
  end

  def permitted_attributes_for_create
    %i[
      name
      default_witness
      default_witness_name
      source_file: [data filename content_type identify]
    ]
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
