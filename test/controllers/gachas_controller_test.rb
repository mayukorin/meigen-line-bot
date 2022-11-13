require "test_helper"

class GachasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get gachas_index_url
    assert_response :success
  end
end
