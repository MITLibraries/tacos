require 'test_helper'

class ReportControllerTest < ActionDispatch::IntegrationTest
  test 'report index is not accessible without authentication' do
    get '/report'

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'report index is accessible to admins when authenticated' do
    sign_in users(:admin)

    get '/report'

    assert_response :success
  end

  test 'report index url is accessible to basic users when authenticated' do
    sign_in users(:basic)

    get '/report'

    assert_response :success
  end

  test 'algorithm metrics report is not accessible without authentication' do
    get '/report/algorithm_metrics'

    assert_redirected_to '/'
    follow_redirect!

    assert_select 'div.alert', text: 'Please sign in to continue', count: 1
  end

  test 'algorithm metrics report is accessible to admins when authenticated' do
    sign_in users(:admin)

    get '/report/algorithm_metrics'

    assert_response :success
  end

  test 'algorithm metrics report is accessible to basic users when authenticated' do
    sign_in users(:basic)

    get '/report/algorithm_metrics'

    assert_response :success
  end

  test 'algorithm metrics can show monthly data' do
    sign_in users(:basic)

    get '/report/algorithm_metrics'

    assert_select 'h3', text: 'Monthly Algorithm Metrics', count: 1
  end

  test 'algorithm metrics can show aggregate data' do
    sign_in users(:basic)

    get '/report/algorithm_metrics?type=aggregate'

    assert_select 'h3', text: 'Aggregate Algorithm Metrics', count: 1
  end
end
