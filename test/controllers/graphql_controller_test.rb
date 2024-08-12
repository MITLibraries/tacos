# frozen_string_literal: true

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

  test 'search event query can return detected standard identifiers' do
    post '/graphql', params: { query: '{
                                 logSearchEvent(sourceSystem: "timdex", searchTerm: "10.1038/nphys1170") {
                                  standardIdentifiers {
                                        kind
                                        value
                                  }
                                 }
                               }' }

    json = JSON.parse(response.body)

    assert_equal('doi', json['data']['logSearchEvent']['standardIdentifiers'].first['kind'])
    assert_equal('10.1038/nphys1170', json['data']['logSearchEvent']['standardIdentifiers'].first['value'])
  end

  test 'search event query can return phrase from logged term' do
    post '/graphql', params: { query: '{
                                 logSearchEvent(sourceSystem: "timdex", searchTerm: "10.1038/nphys1170") {
                                  phrase
                                 }
                               }' }

    json = JSON.parse(response.body)

    assert_equal('10.1038/nphys1170', json['data']['logSearchEvent']['phrase'])
  end

  test 'search event query can return details for detected standard identifiers' do
    VCR.use_cassette('searchevent 10.1038/nphys1170') do
      post '/graphql', params: { query: '{
                                 logSearchEvent(sourceSystem: "timdex", searchTerm: "10.1038/nphys1170") {
                                  standardIdentifiers {
                                        kind
                                        value
                                        details {
                                          title
                                          linkResolverUrl
                                          issns
                                          authors
                                        }
                                  }
                                 }
                               }' }

      json = JSON.parse(response.body)

      assert_equal('Measured measurement',
                   json['data']['logSearchEvent']['standardIdentifiers'].first['details']['title'])
      assert_equal('https://mit.primo.exlibrisgroup.com/discovery/openurl?institution=01MIT_INST&rfr_id=info:sid/mit.tacos.api&vid=01MIT_INST:MIT&rft.atitle=Measured measurement&rft.date=&rft.genre=journal-article&rft.jtitle=Nature Physics&rft_id=info:doi/10.1038/nphys1170',
                   json['data']['logSearchEvent']['standardIdentifiers'].first['details']['linkResolverUrl'])
      assert_equal(%w[1745-2473 1745-2481],
                   json['data']['logSearchEvent']['standardIdentifiers'].first['details']['issns'])
      assert_nil(json['data']['logSearchEvent']['standardIdentifiers'].first['details']['authors'])
    end
  end
end
