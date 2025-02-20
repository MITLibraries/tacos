# frozen_string_literal: true

require 'test_helper'

class DemoControllerTest < ActionDispatch::IntegrationTest
  test 'demo url is accessible without authentication' do
    get '/demo'

    assert_response :success
  end

  test 'can submit query without authentication' do
    post '/demo', params: { query: 'good greetings' }

    assert_response :success
  end

  test 'term is nil if not seen previously in non-simulation runs' do
    post '/demo', params: { query: 'good greetings' }

    assert_nil @controller.instance_variable_get(:@term)
  end

  test 'term is provide if seen previously in non-simulation runs' do
    post '/demo', params: { query: terms('cool').phrase }

    assert_not_nil @controller.instance_variable_get(:@term)
    assert_equal('Super cool search', @controller.instance_variable_get(:@term).phrase)
  end

  test 'citation data is provided' do
    post '/demo', params: { query: terms('citation').phrase }

    assert_operator @controller.instance_variable_get(:@detections)[:citation].last, :>, 10
  end

  test 'journals data is provided' do
    post '/demo', params: { query: terms('journal_nature_medicine').phrase }

    assert_equal('nature medicine', @controller.instance_variable_get(:@detections)[:journals].first[:name])
  end

  test 'lcsh data is provided' do
    post '/demo', params: { query: terms('lcsh').phrase }

    assert_equal('Geology -- Massachusetts', @controller.instance_variable_get(:@detections)[:lcsh][:separator])
  end

  test 'standard identifiers data is provided' do
    post '/demo', params: { query: terms('doi').phrase }

    assert_equal('10.1016/j.physio.2010.12.004', @controller.instance_variable_get(:@detections)[:standard_identifiers][:doi])
  end

  test 'suggested resources data is provided' do
    post '/demo', params: { query: terms('jstor').phrase }

    assert_equal('JSTOR', @controller.instance_variable_get(:@detections)[:suggested_resources].first.title)
  end
end
