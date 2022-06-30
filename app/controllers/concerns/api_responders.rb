# frozen_string_literal: true

module ApiResponders
  extend ActiveSupport::Concern

  private

  def respond_with_record_errors(record, status = :unprocessable_entity)
    render(
      json:   record.errors.as_json(full_messages: true),
      status:
    )
  end
end
