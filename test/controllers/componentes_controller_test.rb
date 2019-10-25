require 'test_helper'

class ComponentesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get componentes_index_url
    assert_response :success
  end

end
