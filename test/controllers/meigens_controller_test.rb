require "test_helper"

class MeigensControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get meigens_show_url
    assert_response :success
  end
end
