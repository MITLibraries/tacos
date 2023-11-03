require 'test_helper'

class GraphqlControllerTest < ActionDispatch::IntegrationTest
  test 'search event query returns relevant data' do
    post '/graphql', params: { query: '{
                                 logSearchEvent(sourceSystem: "bento", searchTerm: "range life") {
                                   termId
                                   source
                                   createdAt
                                   updatedAt
                                 }
                               }' }
    assert_equal(200, response.status)
    json = JSON.parse(response.body)
    term_id = Term.last.id

    assert_equal 'bento', json['data']['logSearchEvent']['source']
    assert_equal term_id, json['data']['logSearchEvent']['termId']
    assert_equal Date.today, json['data']['logSearchEvent']['createdAt'].to_date
    assert_equal Date.today, json['data']['logSearchEvent']['updatedAt'].to_date
  end

  test 'search event query creates a new term if one does not exist' do
    initial_term_count = Term.count
    post '/graphql', params: { query: '{
                                 logSearchEvent(sourceSystem: "bento", searchTerm: "range life") {
                                   termId
                                   source
                                   createdAt
                                   updatedAt
                                 }
                               }' }
    assert_equal(200, response.status)
    assert_equal Term.count, (initial_term_count + 1)
    assert_equal 'range life', Term.last.phrase
  end

  test 'search event query does not create a new term if phrase is already stored' do
    initial_term_count = Term.count
    post '/graphql', params: { query: '{
                                 logSearchEvent(sourceSystem: "timdex", searchTerm: "Super cool search") {
                                   termId
                                   source
                                   createdAt
                                   updatedAt
                                 }
                               }' }
    assert_equal(200, response.status)
    assert_equal Term.count, initial_term_count
  end
end
