require 'spec_helper'

describe "todos/show.html.haml" do
  before(:each) do
    @todo = assign(:todo, stub_model(Todo,
      :content => "MyText",
      :order => 1,
      :done => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
  end
end
