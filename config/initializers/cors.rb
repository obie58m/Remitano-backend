# frozen_string_literal: true

frontend_origins = ENV.fetch("FRONTEND_ORIGIN", "http://localhost:5173,http://127.0.0.1:5173")
                    .split(",")
                    .map(&:strip)
                    .reject(&:blank?)

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*frontend_origins)

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: [ "Authorization" ]
  end
end
