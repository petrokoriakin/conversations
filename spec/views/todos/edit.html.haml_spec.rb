require 'spec_helper'

describe "todos/edit.html.haml" do
  before(:each) do
    @todo = assign(:todo, stub_model(Todo,
      :content => "MyText",
      :order => 1,
      :done => false
    ))
  end

  it "renders the edit todo form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => todos_path(@todo), :method => "post" do
      assert_select "textarea#todo_content", :name => "todo[content]"
      assert_select "input#todo_order", :name => "todo[order]"
      assert_select "input#todo_done", :name => "todo[done]"
    end
  end
end
