# frozen_string_literal: true

# Idempotent demo data for reviewers (password: password1234)
alice = User.find_or_initialize_by(email: "demo@example.com")
if alice.new_record?
  alice.assign_attributes(
    name: "Demo User",
    password: "password1234",
    password_confirmation: "password1234"
  )
  alice.save!
end

Rails.logger.info { "Seeds done. Demo login: demo@example.com / password1234" }
