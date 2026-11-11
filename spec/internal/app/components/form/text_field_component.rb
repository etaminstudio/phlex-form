# frozen_string_literal: true

module Form
  class TextFieldComponent < Phlex::Form::LabelComponent
    def view_template
      plain "my custom text_field"
    end
  end
end
