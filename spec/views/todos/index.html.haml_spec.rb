require 'spec_helper'

describe "todos/index.html.haml" do
  before(:each) do
    assign(:todos, [
      stub_model(Todo,
        :content => "MyText",
        :order => 1,
        :done => false
      ),
      stub_model(Todo,
        :content => "MyText",
        :order => 1,
        :done => false
      )
    ])
  end

  it "renders a list of todos" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
