ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require "action_cable/test_helper"

module ActiveSupport
  class TestCase
    parallelize(workers: 1)

    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
end

class ActiveJob::TestCase
  include ActionCable::TestHelper
end
