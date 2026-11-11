# frozen_string_literal: true

module Phlex
  module Form
    class BaseComponent < Phlex::Form.configuration.parent_component.constantize
      # Rails' `class_names`, usable before rendering too (components build their options in `initialize`), unlike
      # phlex-rails' helper adapter, which needs the view context.
      TAG_HELPER = Object.new.extend(ActionView::Helpers::TagHelper)

      # Options the builder passes for Rails' tag classes, which take them out (see `objectify_options` and
      # `ActionView::Helpers::Tags::Base`): not HTML attributes.
      BUILDER_OPTIONS = %i[object index namespace skip_default_ids allow_method_names_outside_object].freeze

      class << self
        attr_accessor :default_options
      end

      # Not `form` and `object` (view_component-form's names), which would hide Phlex's `<form>` and `<object>`
      # element methods.
      attr_reader :form_builder, :object_name, :options

      def initialize(form_builder, object_name, options = {})
        @form_builder = form_builder

        # See: https://github.com/rails/rails/blob/83217025a171593547d1268651b446d3533e2019/actionview/lib/action_view/helpers/tags/base.rb#L13
        @object_name = object_name.to_s.dup
        @options     = options

        super()
      end

      def form_object
        form_builder&.object
      end

      def object_errors?
        return false unless form_object.respond_to?(:errors)

        form_object.errors.any?
      end

      def object_errors
        return nil unless form_object.respond_to?(:errors)

        form_object.errors
      end

      def html_class
        nil
      end

      # The block the component was rendered with, captured with the component as its argument (as Rails yields its
      # builders): from a template (ERB, Slim…), what it outputs; from a Phlex view, what it renders.
      def content
        return @content if defined?(@content)

        @content = (capture(self, &@content_block).presence if @content_block)
      end

      # Phlex checks `render?` before handing the block to the template: keep it at hand from the start, so that
      # `render?` and `before_render` can read the content, as in ViewComponent.
      def internal_call(parent: nil, state: nil, &block)
        @content_block = block || @_content_block

        super
      end

      protected

      def before_render
        super if defined?(super)

        combine_options!
      end

      def combine_options!
        @options = (self.class.default_options.deep_dup || {}).deep_merge(options).tap do |opts|
          opts[:class] = class_names(options[:class], html_class) if (html_class || options[:class]).present?
        end
      end

      private

      # The options as HTML attributes, for a component rendering its own tag rather than a Rails tag class
      def html_attributes
        options.except(*BUILDER_OPTIONS)
      end

      def class_names(...)
        TAG_HELPER.class_names(...)
      end

      def before_template(...)
        before_render

        super
      end
    end
  end
end
