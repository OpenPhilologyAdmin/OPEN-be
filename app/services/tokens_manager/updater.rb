# frozen_string_literal: true

module TokensManager
  class Updater < Base
    def perform!
      success = update_token
      update_last_editor if success

      Result.new(
        success:,
        token:   @token
      )
    end

    private

    def update_token
      @token.assign_attributes(@params)
      calculate_new_grouped_variants
      @token.save
    end

    def update_last_editor
      @token.project.update(last_editor: @user)
    end

    def calculate_new_grouped_variants
      return unless @token.valid?
      return unless @token.will_save_change_to_variants?

      @token.grouped_variants = variants_hash.map do |(variant, witnesses)|
        TokenGroupedVariant.new(
          t:         variant,
          witnesses:,
          selected:  false,
          possible:  false
        )
      end
    end

    def variants_hash
      @variants_hash ||= Hash.new { |h, k| h[k] = [] }
      @token.variants.each do |variant|
        @variants_hash[variant.t] << variant.witness
      end
      @variants_hash
    end
  end
end
