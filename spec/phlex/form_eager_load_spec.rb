# frozen_string_literal: true

require "open3"
require "rbconfig"

RSpec.describe Phlex::Form do
  it "does not load the controller test case during eager loading" do
    script = <<~RUBY
      require "rails"
      require "action_controller"
      require "phlex/form"

      Zeitwerk::Loader.eager_load_namespace(Phlex::Form)

      puts ActionController::Live.instance_method(:new_controller_thread).source_location.first
    RUBY

    output, status = run_in_clean_process(script)

    expect(status).to be_success, output
    expect(output).to end_with("action_controller/metal/live.rb\n")
  end

  it "allows explicit requires of the test helpers" do
    script = <<~RUBY
      require "rails"
      require "action_controller"
      require "phlex/form"
      require "phlex/form/test_helpers"

      puts Phlex::Form::TestHelpers.name
    RUBY

    output, status = run_in_clean_process(script)

    expect(status).to be_success, output
    expect(output).to end_with("Phlex::Form::TestHelpers\n")
  end

  it "autoloads the test helpers" do
    script = <<~RUBY
      require "rails"
      require "action_controller"
      require "phlex/form"

      puts Phlex::Form::TestHelpers.name
    RUBY

    output, status = run_in_clean_process(script)

    expect(status).to be_success, output
    expect(output).to end_with("Phlex::Form::TestHelpers\n")
  end

  def run_in_clean_process(script)
    Open3.capture2e(
      { "RUBYOPT" => "-rbundler/setup" },
      RbConfig.ruby,
      "-e",
      script,
      chdir: File.expand_path("../..", __dir__)
    )
  end
end
