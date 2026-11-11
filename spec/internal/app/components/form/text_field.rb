# frozen_string_literal: true

module Form
  class TextField < Phlex::Form::LabelComponent
    def view_template
      plain "my custom text_field"
    end
  end
end
