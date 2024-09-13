require 'test_helper'

class StaticControllerTest < ActionDispatch::IntegrationTest
  test 'root url is accessible without authentication' do
    get '/'

    assert_response :success
  end

  test 'playground url is not accessible without authentication' do
    get '/playground'

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'playground url is accessible to admins when authenticated' do
    sign_in users(:admin)

    get '/playground'

    assert_response :success
  end

  test 'playground url is not accessible to basic users when authenticated' do
    sign_in users(:basic)

    get '/playground'

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Not authorized.', count: 1
  end
end
