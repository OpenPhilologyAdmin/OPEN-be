# frozen_string_literal: true

module TokensResizer
  class TokensBuilder
    def initialize(selected_text:, selected_tokens:, project:)
      @selected_text                   = selected_text
      @selected_tokens                 = selected_tokens
      @project                         = project
    end

    def self.perform(selected_text:, selected_tokens:, project:)
      new(selected_text:, selected_tokens:, project:).perform
    end

    def perform
      before_section, after_section = sections

      tokens = []
      tokens << build_token(t: before_section) if before_section.present?
      tokens << build_token(t: selected_text, for_selected_text: true)
      tokens << build_token(t: after_section) if after_section.present?
      tokens
    end

    private

    def multiple_grouped_variants_token
      @multiple_grouped_variants_token ||= selected_tokens.detect { |token| !token.one_grouped_variant? }
    end

    # rubocop:disable Naming/MethodParameterName
    def build_token(t:, for_selected_text: false)
      token                  = Token.new(project:, variants: variants(t:, for_selected_text:))
      token.grouped_variants = TokensManager::GroupedVariantsGenerator.perform(token:)
      # TODO: preserve selections
      token
    end

    def variants(t:, for_selected_text: false)
      if for_selected_text && multiple_grouped_variants_token.present?
        variants_for_multiple_grouped_variants_token
      else
        project.witnesses.map do |witness|
          TokenVariant.new(t:, witness: witness.siglum)
        end
      end
    end

    # rubocop:enable Naming/MethodParameterName

    def variants_for_multiple_grouped_variants_token
      prefix, suffix = suffixes
      multiple_grouped_variants_token.variants.map do |variant|
        TokenVariant.new(t: "#{prefix}#{variant.t}#{suffix}", witness: variant.witness)
      end
    end

    # [before_section, after_section] for new tokens that surround the selected_text token
    def sections
      full_text           = selected_tokens.map(&:t).join
      selected_text_index = full_text.index(selected_text)

      [
        full_text[0...selected_text_index],
        full_text[(selected_text_index + selected_text.length)...]
      ]
    end

    # [prefix, suffix] that should be added to all variants of the multiple grouped variants token
    def suffixes
      token_t       = multiple_grouped_variants_token.t
      token_t_index = selected_text.index(token_t)

      [
        selected_text[0...token_t_index],
        selected_text[(token_t_index + token_t.length)...]
      ]
    end

    attr_reader :selected_text, :selected_tokens, :project
  end
end
