require "test_helper"

class SecretaryControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get secretary_index_url
    assert_response :success
  end
end
