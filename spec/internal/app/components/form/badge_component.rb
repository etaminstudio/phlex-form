# frozen_string_literal: true

module Form
  class BadgeComponent < Phlex::Form::FieldComponent
    def initialize(form, object_name, method_name, label:, **options)
      @label = label

      super(form, object_name, method_name, options)
    end

    def view_template
      span(class: "badge-#{method_name}") { @label }
    end
  end
end
