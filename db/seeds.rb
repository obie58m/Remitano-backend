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

demo_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
unless SharedVideo.exists?(user: alice, youtube_url: demo_url)
  SharedVideo.create!(
    user: alice,
    youtube_url: demo_url,
    title: "Demo shared video"
  )
end

Rails.logger.info { "Seeds done. Demo login: demo@example.com / password1234" }
