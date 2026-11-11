# frozen_string_literal: true

require "action_view"
require "phlex-rails"
require "zeitwerk"

module Phlex
  module Form
    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield configuration
      end
    end
  end
end

loader = Zeitwerk::Loader.new
loader.tag = "phlex-form"
loader.inflector.inflect("version" => "VERSION")
loader.push_dir("#{__dir__}/form", namespace: Phlex::Form)
loader.do_not_eager_load("#{__dir__}/form/test_helpers.rb")
loader.setup
