# frozen_string_literal: true

module Form
  class LabelComponent < Phlex::Form::LabelComponent
    def view_template
      plain "my custom label"
    end
  end
end
