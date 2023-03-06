# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def index?
    approved_admin?
  end

  def create?
    approved_admin?
  end

  def update?
    approved_admin?
  end

  def show?
    approved_admin?
  end

  def destroy?
    approved_admin? && record.creator == user
  end

  def export?
    approved_admin?
  end

  def manage_witnesses?
    show?
  end

  def index_witnesses?
    manage_witnesses?
  end

  def create_witnesses?
    manage_witnesses?
  end

  def update_witnesses?
    manage_witnesses?
  end

  def destroy_witnesses?
    manage_witnesses? && record.witnesses_count > 1
  end

  def permitted_attributes_for_create
    [
      :name,
      :default_witness,
      :default_witness_name,
      { source_file: %i[data filename content_type identify] }
    ]
  end

  def permitted_attributes_for_update
    [:name]
  end

  def permitted_attributes_for_export
    %w[
      significant_readings
      insignificant_readings
      footnote_numbering
      selected_reading_separator
      readings_separator
      sigla_separator
    ]
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
