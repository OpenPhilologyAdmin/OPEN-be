# frozen_string_literal: true

class EditedTokensEvaluator
  def initialize(project:, selected_token_ids:)
    @project = project
    @selected_tokens = project.tokens
                              .where(id: selected_token_ids)
                              .includes(:comments)
  end

  def self.perform(project:, selected_token_ids:)
    new(project:, selected_token_ids:).perform
  end

  def perform
    result
  end

  private

  attr_reader :project, :selected_tokens

  def result
    @result ||= {
      comments:            comments?,
      editorial_remarks:   editorial_remarks?,
      variants_selections: variants_selections?
    }
  end

  def comments?
    selected_tokens.any? { |token| token.comments.any? }
  end

  def editorial_remarks?
    selected_tokens.any? { |token| token.editorial_remark.present? }
  end

  def variants_selections?
    selected_tokens.any?(&:evaluated?)
  end
end
