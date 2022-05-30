# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*ENV.fetch('FRONTEND_APP_ORIGINS', '').split(',').map(&:strip))

    resource(
      '*',
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose:  %i[Authorization]
    )
  end
end
