# frozen_string_literal: true

# The builder in the views it's used from: a template (ERB) or a Phlex view (through phlex-rails' `form_with`).
# In each, a form renders the same HTML as with Rails' own FormBuilder, blocks included.
RSpec.describe Phlex::Form::Builder, type: :component do
  let(:address_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :id, :integer
      attribute :city, :string

      def self.model_name = ActiveModel::Name.new(self, nil, "Address")
      def persisted? = true
    end
  end

  let(:record_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :name, :string
      attribute :role, :string
      attribute :tag_ids, default: -> { [] }
      attr_accessor :address

      def self.model_name = ActiveModel::Name.new(self, nil, "Record")
      def address_attributes=(_attributes); end
    end
  end

  let(:record) do
    record_class.new(name: "Ada", role: "editor", tag_ids: [2], address: address_class.new(id: 7, city: "Lyon"))
  end
  let(:tags) { [OpenStruct.new(id: 1, name: "Red"), OpenStruct.new(id: 2, name: "Blue")] }

  let(:erb) do
    <<~ERB
      <%= form_with model: record, scope: :record, url: "/records", builder: builder do |f| %>
        <%= f.label :name %>
        <%= f.label :name do %>Custom <b>name</b><% end %>
        <%= f.text_field :name, class: "input" %>
        <%= f.select :role, [["Admin", "admin"], ["Editor", "editor"]] %>
        <%= f.select :role do %><option value="x">X</option><% end %>
        <%= f.collection_check_boxes :tag_ids, tags, :id, :name do |b| %><%= b.label { b.check_box } %><% end %>
        <%= f.fields_for :address do |af| %><%= af.text_field :city %><% end %>
        <%= f.button do %>Save <i>now</i><% end %>
        <%= f.submit %>
      <% end %>
    ERB
  end

  let(:phlex_view) do
    Class.new(Phlex::HTML) do
      include Phlex::Rails::Helpers::FormWith

      def initialize(record:, tags:, builder:)
        @record = record
        @tags = tags
        @builder = builder

        super()
      end

      def view_template # rubocop:disable Metrics/AbcSize, Metrics/MethodLength -- one call per helper
        form_with(model: @record, scope: :record, url: "/records", builder: @builder) do |f|
          f.label(:name)
          f.label(:name) do
            plain "Custom "
            b { "name" }
          end
          f.text_field(:name, class: "input")
          f.select(:role, [%w[Admin admin], %w[Editor editor]])
          f.select(:role) { option(value: "x") { "X" } }
          f.collection_check_boxes(:tag_ids, @tags, :id, :name) { |b| b.label { b.check_box } }
          f.fields_for(:address) { |af| af.text_field(:city) }
          f.button do
            plain "Save "
            i { "now" }
          end
          f.submit
        end
      end
    end
  end
  let(:rails_html) { render_template(erb, :erb, ActionView::Helpers::FormBuilder) }

  def render_template(source, type, builder)
    normalize(template.render(inline: source, type:, locals: { record:, tags:, builder: }))
  end

  def render_phlex(builder)
    normalize(template.render(phlex_view.new(record:, tags:, builder:)))
  end

  # Whitespace between tags differs from one template language to another: one tag per line, for readable diffs
  def normalize(html)
    html.gsub(/>\s*</, ">\n<").strip
  end

  it "renders a form like Rails" do
    expect(rails_html.lines.map(&:strip)).to include(
      "<label>Custom <b>name</b>",
      '<input type="checkbox" value="2" checked="checked" name="record[tag_ids][]" id="record_tag_ids_2" />',
      '<input type="text" value="Lyon" name="record[address_attributes][city]" id="record_address_attributes_city" />',
      '<input autocomplete="off" type="hidden" value="7" name="record[address_attributes][id]" ' \
      'id="record_address_attributes_id" />',
      '<button name="button" type="submit">Save <i>now</i>'
    )
  end

  it "renders from ERB as Rails does" do
    expect(render_template(erb, :erb, described_class)).to eq(rails_html)
  end

  it "renders from a Phlex view as Rails does" do
    expect(render_phlex(described_class)).to eq(render_phlex(ActionView::Helpers::FormBuilder))
    expect(render_phlex(described_class)).to eq(rails_html)
  end
end
