# frozen_string_literal: true

module WitnessesManager
  class Updater < Base
    def initialize(project:, siglum:, user:, params: nil)
      @default_witness_value = as_boolean(params.delete(:default))
      super
    end

    def perform
      update_witness
      handle_default_witness_change
      Result.new(
        success: @project.save,
        witness: @witness
      )
    end

    private

    def update_witness
      @witness.assign_attributes(@params)
    end

    def handle_default_witness_change
      return unless @witness.valid?

      @witness.assign_default(@default_witness_value)
    end

    def as_boolean(value)
      ActiveModel::Type::Boolean.new.cast(value)
    end
  end
end
