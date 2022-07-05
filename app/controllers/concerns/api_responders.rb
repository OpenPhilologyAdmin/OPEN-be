# frozen_string_literal: true

module ApiResponders
  extend ActiveSupport::Concern

  private

  def respond_with_record_errors(record, status = :unprocessable_entity)
    render(
      json:   record_errors(record),
      status:
    )
  end

  def record_errors(record)
    record.errors.as_json(full_messages: true)
  end
end
