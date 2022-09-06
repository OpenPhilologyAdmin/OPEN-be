# frozen_string_literal: true

class WitnessPolicy < ApplicationPolicy
  def initialize(user, _record)
    @user = user
    super
  end

  def permitted_attributes_for_create
    %i[
      name
      siglum
    ]
  end

  def permitted_attributes_for_update
    %i[
      name
      default
    ]
  end
end
