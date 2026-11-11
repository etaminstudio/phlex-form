# frozen_string_literal: true

module InlineForm
  class LabelComponent < Phlex::Form::LabelComponent
    def view_template
      plain "my custom label for inline form"
    end
  end
end
