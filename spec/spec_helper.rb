# frozen_string_literal: true

if ENV.fetch("COVERAGE", false)
  require "simplecov"
  SimpleCov.start do
    skip "/spec"

    minimum_coverage 89
    maximum_coverage_drop 2
  end
end

require "combustion"

Combustion.path = "spec/internal"

modules = %i[action_controller action_view active_record active_storage]
modules << :action_text if ENV.fetch("PHLEX_FORM_USE_ACTIONTEXT", "false") == "true"

Combustion.initialize!(*modules) do
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(nil))
  config.log_level = :fatal
end

require "generator_spec"

class ApplicationController < ActionController::Base
end

require "phlex/form/test_helpers"
require "capybara/rspec"
require "ostruct"

Dir["./spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Phlex::Form::TestHelpers, type: :component
  config.include Phlex::Form::TestHelpers, type: :builder
  config.include Capybara::RSpecMatchers, type: :component
  config.include RSpecHtmlMatchers, type: :component

  config.include ActiveSupport::Testing::TimeHelpers

  config.after { travel_back }
end
