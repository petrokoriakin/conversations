require 'test_helper'

class DemoControllerTest < ActionController::TestCase
  test "should get backbone" do
    get :backbone
    assert_response :success
  end

  test "should get polling" do
    get :polling
    assert_response :success
  end

end
