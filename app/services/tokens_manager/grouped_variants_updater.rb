# frozen_string_literal: true

module TokensManager
  class GroupedVariantsUpdater < Updater
    ALLOWED_UPDATE_ATTRIBUTES = %i[selected possible].freeze

    delegate :grouped_variants, to: :token

    private

    def update_token
      update_grouped_variants
      token.save
    end

    def update_grouped_variants
      grouped_variants_to_update = params[:grouped_variants]
      if grouped_variants_to_update.blank?
        token.grouped_variants = []
      else
        grouped_variants_to_update.each do |grouped_variant_to_update|
          update_selections(grouped_variant_to_update)
        end
      end
    end

    def update_selections(grouped_variant_to_update)
      grouped_variant = grouped_variants.find { |record| record.id == grouped_variant_to_update[:id] }
      grouped_variant.assign_attributes(grouped_variant_to_update.slice(*ALLOWED_UPDATE_ATTRIBUTES))
    end
  end
end
