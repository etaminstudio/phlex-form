# Phlex::Form

**`Phlex::Form`** is a customizable form builder using the same interface as [`ActionView::Helpers::FormBuilder`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html) but with extensible [Phlex](https://www.phlex.fun) components. It works in ERB (or any template language) and in Phlex views alike.

It is derived from [`view_component-form`](https://github.com/pantographe/view_component-form), with the same API, rendering Phlex components instead of ViewComponents.

Development of this gem is sponsored by:

<a href="https://etamin.studio/?ref=phlex-form"><img src="https://etamin.studio/images/logo.svg" alt="Sponsored by Etamin Studio" width="184" height="22"></a>

## Compatibility

> [!WARNING]
> **This is an early release, and the API is subject to change until `v1.0.0`.**

This gem is tested on:

- Rails 8.1+ (with or without ActionText)
- Ruby 3.3+
- Phlex 2.4+ (with `phlex-rails`)

## Installation

```shell
bundle add phlex-form
```

### Configuration

```ruby
# config/initializers/phlex_form.rb

Phlex::Form.configure do |config|
  config.parent_component = 'ApplicationFormComponent'
end
```

| Attribute                   | Purpose                                       | Default         |
| --------------------------- | --------------------------------------------- | --------------- |
| `parent_component` (string) | Parent class for all `Phlex::Form` components | `"Phlex::HTML"` |

#### Configuring component lookup

`Phlex::Form` will automatically infer the component class with a `Component` suffix. You can customize the lookup using the `lookup_chain`:

```rb
# config/initializers/phlex_form.rb

Phlex::Form.configure do |config|
  without_component_suffix = lambda do |component_name, namespaces: []|
    namespaces.lazy.map do |namespace|
      "#{namespace}::#{component_name.to_s.camelize}".safe_constantize
    end.find(&:itself)
  end

  config.lookup_chain.prepend(without_component_suffix)
end
```

`Phlex::Form` will iterate through the `lookup_chain` until a value is returned. By using `prepend` we can fallback on the default `Phlex::Form` lookup.

## Usage

Add your own form builder.

```shell
bin/rails generate phlex_form:builder FormBuilder
      create  app/helpers/form_builder.rb
```

To use the form builder:

- add a `builder` param to your `form_for`, `form_with`, `fields_for` or `fields`:

```diff
- <%= form_for @user do |f| %>
+ <%= form_for @user, builder: FormBuilder do |f| %>
```

- or; set it as a default in your controller using [default_form_builder](https://api.rubyonrails.org/classes/ActionController/FormBuilder.html#method-i-default_form_builder).

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  default_form_builder FormBuilder
end
```

Then use ActionView form builder helpers as you would normally:

```erb
<%# app/views/users/_form.html.erb %>
<%= form_for @user, builder: Phlex::Form::Builder do |f| %>
  <%= f.label :first_name %>        <%# renders a Phlex::Form::LabelComponent %>
  <%= f.text_field :first_name %>   <%# renders a Phlex::Form::TextFieldComponent %>

  <%= f.label :last_name %>         <%# renders a Phlex::Form::LabelComponent %>
  <%= f.text_field :last_name %>    <%# renders a Phlex::Form::TextFieldComponent %>

  <%= f.label :email %>             <%# renders a Phlex::Form::LabelComponent %>
  <%= f.email_field :email %>       <%# renders a Phlex::Form::EmailFieldComponent %>

  <%= f.label :password %>          <%# renders a Phlex::Form::LabelComponent %>
  <%= f.password_field :password, aria: { describedby: f.field_id(:password, :description) } %>
                                    <%# renders a Phlex::Form::PasswordFieldComponent %>
  <div id="<%= f.field_id(:password, :description) %>">
    <%= f.hint :password, 'The password should be at least 8 characters long' %>
                                      <%# renders a Phlex::Form::HintComponent %>
    <%= f.error_message :password %>  <%# renders a Phlex::Form::ErrorMessageComponent %>
  </div>
<% end %>
```

### In a Phlex view

The builder works the same in a Phlex view, through [phlex-rails' `form_with` adapter](https://www.phlex.fun/rails/helpers):

```rb
# app/views/users/form.rb
class Views::Users::Form < Phlex::HTML
  include Phlex::Rails::Helpers::FormWith

  def initialize(user:)
    @user = user
  end

  def view_template
    form_with(model: @user, builder: Phlex::Form::Builder) do |f|
      f.label(:first_name)
      f.text_field(:first_name)

      f.label(:email)
      f.email_field(:email)
      f.error_message(:email)
    end
  end
end
```

A form renders the same HTML from either, and as Rails' own form builder for the standard helpers.

### Customizing built-in components

The `Phlex::Form::Builder` will use the provided `namespace` to find any components you've customized.

```ruby
# app/helpers/form_builder.rb
class FormBuilder < Phlex::Form::Builder
  namespace Form
end
```

Let's customize the `text_field` helper by adding a new component in the namespace defined within the builder.

```ruby
# app/components/form/text_field_component.rb
class Form::TextFieldComponent < Phlex::Form::TextFieldComponent
  def html_class
    class_names("custom-text-field", "has-error": method_errors?)
  end
end
```

In this case we're leveraging the [`#class_names`](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html#method-i-class_names) helper to:

- always add the `custom-text-field` class;
- add the `has-error` class if there is an error on the attribute (using `Phlex::Form::FieldComponent#method_errors?`).

### Adding your own custom helpers and components

Add the helper method to your `Phlex::Form::Builder`

```rb
# app/helpers/form_builder.rb
class FormBuilder < Phlex::Form::Builder
  def year_field(method, options = {})
    render_component(:year_field, @object_name, method, objectify_options(options))
  end

  def money_field(method, currencies = [], options = {})
    render_component(:money_field, @object_name, method, currencies, objectify_options(options))
  end
end
```

Add your component which can optionally inherit from:

- `Phlex::Form::FieldComponent` (suggested when adding a field because of helpers)
- `Phlex::Form::BaseComponent`
- or any of the `Phlex::Form::*Component` such as `Phlex::Form::TextFieldComponent`

```rb
# app/components/form/year_field_component.rb
class Form::YearFieldComponent < Phlex::Form::FieldComponent # or Phlex::Form::BaseComponent
  def view_template
    input(type: "number", name: "#{object_name}[#{method_name}]", value:, min: 1900, max: 2100)
  end
end
```

`render_component` also passes keyword arguments on to your component:

```rb
# app/helpers/form_builder.rb
class FormBuilder < Phlex::Form::Builder
  def badge(method, label:, **options)
    render_component(:badge, @object_name, method, label:, **objectify_options(options))
  end
end
```

```rb
# app/components/form/badge_component.rb
class Form::BadgeComponent < Phlex::Form::FieldComponent
  def initialize(form_builder, object_name, method_name, label:, **options)
    @label = label

    super(form_builder, object_name, method_name, options)
  end

  def view_template
    span(class: "badge-#{method_name}") { @label }
  end
end
```

When inheriting from `Phlex::Form::FieldComponent`, you get access to the following helpers:

#### `#label_text`

Returns the translated text for the label of the field (looking up for `helpers.label.OBJECT.METHOD_NAME`), or humanized version of the method name if not available.

```rb
# app/helpers/form_builder.rb
class FormBuilder < Phlex::Form::Builder
  namespace Custom::Form

  def group(method, options = {}, &)
    render_component(:group, @object_name, method, objectify_options(options), &)
  end
end
```

```rb
# app/components/custom/form/group_component.rb
class Custom::Form::GroupComponent < Phlex::Form::FieldComponent
  def view_template
    div(class: "custom-form-group") do
      label do
        plain label_text
        br
        yield
      end
    end
  end
end
```

```erb
<%# app/views/users/_form.html.erb %>
<%= form_for @user do |f| %>
  <%= f.group :first_name do %>
    <%= f.text_field :first_name %>
  <% end %>
<% end %>
```

```yml
# config/locales/en.yml
en:
  helpers:
    label:
      user:
        first_name: Your first name
```

Renders:

```html
<form
  class="edit_user"
  id="edit_user_1"
  action="/users/1"
  accept-charset="UTF-8"
  method="post"
>
  <!-- ... -->
  <div class="custom-form-group">
    <label>
      Your first name<br />
      <input
        type="text"
        value="John"
        name="user[first_name]"
        id="user_first_name"
      />
    </label>
  </div>
</form>
```

#### `#content`

The block a component was rendered with, captured, with the component as its argument: what it outputs from a template, or what it renders from a Phlex view. For instance, the `label` helper renders its block as the label's content, like Rails.

#### `#form_builder` and `#form_object`

The form builder the component was rendered from, and its object. They aren't named `form` and `object`, so that components can still render Phlex's `<form>` and `<object>` elements.

### Validations

Let's consider the following model for the examples below.

```rb
# app/models/user.rb
class User < ActiveRecord::Base
  validates :first_name, presence: true, length: { minimum: 2, maximum: 255 }
end
```

##### Accessing validations with `#validators`

Returns all validators for the method name.

```rb
# app/components/custom/form/group_component.rb
class Custom::Form::GroupComponent < Phlex::Form::FieldComponent
  def view_template
    div(class: "custom-form-group") do
      label do
        plain "#{label_text} (#{validation_hint})"
        br
        yield
      end
    end
  end

  private

  def validation_hint
    if length_validator
      "between #{length_validator.options[:minimum]} and #{length_validator.options[:maximum]} chars"
    end
  end

  def length_validator
    validators.find { |v| v.is_a?(ActiveModel::Validations::LengthValidator) }
  end
end
```

##### Using `#required?` and `#optional?`

```rb
# app/components/custom/form/group_component.rb
class Custom::Form::GroupComponent < Phlex::Form::FieldComponent
  def view_template
    div(class: "custom-form-group") do
      label do
        plain label_text
        plain " (required)" if required?
        br
        yield
      end
    end
  end
end
```

##### Validation contexts

When using [validation contexts](https://guides.rubyonrails.org/active_record_validations.html#on), you can specify a context to the helpers above.

```rb
# app/models/user.rb
class User < ActiveRecord::Base
  validates :first_name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :email, presence: true, on: :registration
end
```

```erb
<%# app/views/users/_form_.html.erb %>
<%= form_with model: @user,
              builder: Phlex::Form::Builder,
              validation_context: :registration do |f| %>
  <%= f.group :email do %>
    <%= f.email_field :email %>
  <% end %>
<% end %>
```

In this case, `Phlex::Form::Builder` accepts a `validation_context` option and passes it as a default value to the `#validators`, `#required?` and `#optional?` helpers.

Alternatively, you can pass the context to the helpers:

```rb
plain " (required)" if required?(context: :registration)
```

```rb
def length_validator
  validators(context: :registration).find { |v| v.is_a?(ActiveModel::Validations::LengthValidator) }
end
```

### Setting up your own base component class

1. Setup some base component from which the form components will inherit from

```rb
class ApplicationFormComponent < Phlex::HTML
end
```

2. Configure the parent component class

```rb
# config/initializers/phlex_form.rb

Phlex::Form.configure do |config|
  config.parent_component = 'ApplicationFormComponent'
end
```

### Using your form components without a backing model

If you want to ensure that your fields display consistently across your app, you'll need to lean on Rails' own helpers. You may be used to using form tag helpers such as `text_field_tag` to generate tags, or even writing out plain HTML tags. These can't be integrated with a form builder, so they won't offer you the benefits of this gem.

You'll most likely want to use either:

- [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with) and supply a route as the endpoint, e.g. `form_with url: users_path do |f| ...`, or
- [`fields`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-fields), supplying a namespace if necessary. `fields do |f| ...` ought to work in the most basic case.

[`fields_for`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-fields_for) may also be of interest. To make consistent use of `phlex-form`, you'll want to be using these three helpers to build your forms wherever possible.

### Using a plain Ruby object as model

The form object doesn't have to implement the ActiveModel API: a plain Ruby object works too. It has no errors or validators, so its fields are never shown with errors nor marked as required.

As Rails can't infer the param key and the route from such an object, pass `scope:` and `url:` to `form_with`.

```rb
# app/models/post.rb
class Post
  attr_accessor :title, :body

  def initialize(title:, body:)
    @title = title
    @body = body
  end
end
```

```erb
<%# app/views/posts/_form.html.erb %>
<%= form_with model: @post, scope: :post, url: posts_path, builder: Phlex::Form::Builder do |f| %>
  <%= f.label :title %>
  <%= f.text_field :title %>
  <%= f.label :body %>
  <%= f.text_field :body %>
<% end %>
```

## Supported helpers

The following helpers are currently supported by `Phlex::Form`.

### `ActionView::Helpers::FormBuilder`

**Supported:** `button` `check_box` `collection_check_boxes` `collection_radio_buttons` `collection_select` `color_field` `date_field` `date_select` `datetime_field` `datetime_local_field` `datetime_select` `email_field` `fields` `fields_for` `file_field` `field_id` `grouped_collection_select` `hidden_field` `label` `month_field` `number_field` `password_field` `phone_field` `radio_button` `range_field` `rich_textarea` (formerly `rich_text_area` before Rails 8) `search_field` `select` `submit` `telephone_field` `textarea` (formerly `text_area` before Rails 8) `text_field` `time_field` `time_select` `time_zone_select` `to_model` `to_partial_path` `url_field` `week_field` `weekday_select`

**Unsupported for now:** `field_name`

### Specific to `Phlex::Form`

**Supported:** `error_message` `hint`

## Migrating from `view_component-form`

The builder and its helpers are the same. In your own components:

- inherit from `Phlex::Form::*Component` instead of `ViewComponent::Form::*Component`;
- render in `view_template` instead of `call` or a template;
- use `form_builder` and `form_object` instead of `form` and `object`;
- set `parent_component` to a Phlex class (`Phlex::HTML` by default), and rename the `vcf:builder` generator to `phlex_form:builder`.

## Testing your components

### RSpec

#### Configuration

```rb
# spec/rails_helper.rb
require "phlex/form/test_helpers"
require "capybara/rspec"

RSpec.configure do |config|
  config.include Phlex::Form::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
end
```

`Phlex::Form::TestHelpers` provides `form_with`, to build a form for your components, and `render_inline`, which renders a component as the builder does and returns its HTML, parsed.

#### Example

```rb
# spec/components/form/text_field_component_spec.rb
RSpec.describe Form::TextFieldComponent, type: :component do
  let(:object)  { User.new } # replace with a model of your choice
  let(:form)    { form_with(object) }
  let(:options) { {} }

  let(:component) { render_inline(described_class.new(form, object_name, :first_name, options)) }

  context "with simple args" do
    it do
      expect(component.to_html)
        .to have_tag("input", with: { name: "user[first_name]", id: "user_first_name", type: "text" })
    end
  end
end
```

For more complex components, we recommend the [`rspec-html-matchers` gem](https://github.com/kucaahbe/rspec-html-matchers).

### Minitest

#### Configuration

```rb
# test/test_helper.rb
require "phlex/form/test_helpers"

ActiveSupport::TestCase.include(Phlex::Form::TestHelpers)
```

#### Example

```rb
# test/components/form/text_field_component_test.rb
class Form::TextFieldComponentTest < ActiveSupport::TestCase
  test "renders a text field" do
    object = User.new # replace with a model of your choice
    form = form_with(object)

    html = render_inline(Form::TextFieldComponent.new(form, object_name, :first_name, {}))

    assert html.at_css("input[type=text][name='user[first_name]'][id='user_first_name']")
  end
end
```

### Object name

`form_with` names the form after the object's model (e.g. `user` for a `User`), like Rails' `form_with(model:)`. For objects that aren't models, it falls back to `object_name`, which returns `:user`. With another model than `User`, pass `form.object_name` to your components instead of `object_name`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, run `bin/release x.x.x`, which will update the `version.rb` file, open the changelog for edition, create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/etaminstudio/phlex-form.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
