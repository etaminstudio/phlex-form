# frozen_string_literal: true

require "action_controller"
require "action_controller/test_case"
require "action_view"

module Phlex
  module Form
    module TestHelpers
      def form_with(object, builder: Phlex::Form::Builder, **options)
        name = object.class.respond_to?(:model_name) ? object.class.model_name.param_key : object_name

        builder.new(name, object, template, options)
      end

      def object_name
        :user
      end

      # The view the forms are built on, and their components rendered in: a controller's, as in an app, so that it
      # has the app's helpers and routes (e.g. Active Storage's direct uploads URL).
      def template
        @template ||= begin
          controller = ApplicationController.new
          controller.request = ActionDispatch::TestRequest.create
          controller.view_context
        end
      end

      # Renders a component in the template, as a builder does, and returns its HTML parsed.
      def render_inline(component, &)
        Nokogiri::HTML5.fragment(component.render_in(template, &))
      end
    end
  end
end
