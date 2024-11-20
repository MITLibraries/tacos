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
    json = response.parsed_body
    term_id = Term.last.id

    assert_equal 'bento', json['data']['logSearchEvent']['source']
    assert_equal term_id, json['data']['logSearchEvent']['termId']
    assert_equal Time.zone.today, json['data']['logSearchEvent']['createdAt'].to_date
    assert_equal Time.zone.today, json['data']['logSearchEvent']['updatedAt'].to_date
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
                                   detectors {
                                     standardIdentifiers {
                                       kind
                                       value
                                     }
                                   }
                                 }
                               }' }

    json = response.parsed_body

    assert_equal('doi', json['data']['logSearchEvent']['detectors']['standardIdentifiers'].first['kind'])
    assert_equal('10.1038/nphys1170', json['data']['logSearchEvent']['detectors']['standardIdentifiers'].first['value'])
  end

  test 'search event query can return detected journals' do
    post '/graphql', params: { query: '{
                                 logSearchEvent(sourceSystem: "timdex", searchTerm: "nature") {
                                   detectors {
                                     journals {
                                       title
                                       additionalInfo
                                     }
                                   }
                                 }
                               }' }

    json = response.parsed_body

    assert_equal('nature', json['data']['logSearchEvent']['detectors']['journals'].first['title'])
    assert_equal({ 'issns' => %w[0028-0836 1476-4687] },
                 json['data']['logSearchEvent']['detectors']['journals'].first['additionalInfo'])
  end

  test 'search event query can return detected suggested resources' do
    post '/graphql', params: { query: '{
                                 logSearchEvent(sourceSystem: "timdex", searchTerm: "web of science") {
                                   detectors {
                                     suggestedResources {
                                       title
                                       url
                                     }
                                   }
                                 }
                               }' }

    json = response.parsed_body

    assert_equal 'Web of Science',
                 json['data']['logSearchEvent']['detectors']['suggestedResources'].first['title']
    assert_equal 'https://libguides.mit.edu/webofsci',
                 json['data']['logSearchEvent']['detectors']['suggestedResources'].first['url']
  end

  test 'search event query can return detected library of congress subject headings' do
    post '/graphql', params: { query: '{
                                 logSearchEvent(sourceSystem: "timdex", searchTerm: "Maryland -- Geography") {
                                   detectors {
                                     lcsh
                                   }
                                 }
                               }' }
    json = response.parsed_body

    assert_equal 'Maryland -- Geography',
                 json['data']['logSearchEvent']['detectors']['lcsh'].first
  end

  test 'search event query can return phrase from logged term' do
    post '/graphql', params: { query: '{
                                 logSearchEvent(sourceSystem: "timdex", searchTerm: "10.1038/nphys1170") {
                                  phrase
                                 }
                               }' }

    json = response.parsed_body

    assert_equal('10.1038/nphys1170', json['data']['logSearchEvent']['phrase'])
  end

  test 'search event query can return details for detected standard identifiers' do
    VCR.use_cassette('searchevent 10.1038/nphys1170') do
      post '/graphql', params: { query: '{
                                   logSearchEvent(sourceSystem: "timdex", searchTerm: "10.1038/nphys1170") {
                                     detectors {
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
                                   }
                                 }' }

      json = response.parsed_body

      assert_equal('Measured measurement',
                   json['data']['logSearchEvent']['detectors']['standardIdentifiers'].first['details']['title'])
      assert_equal('https://mit.primo.exlibrisgroup.com/discovery/openurl?institution=01MIT_INST&rfr_id=info:sid/mit.tacos.api&vid=01MIT_INST:MIT&rft.atitle=Measured measurement&rft.date=&rft.genre=journal-article&rft.jtitle=Nature Physics&rft_id=info:doi/10.1038/nphys1170',
                   json['data']['logSearchEvent']['detectors']['standardIdentifiers'].first['details']['linkResolverUrl'])
      assert_equal(%w[1745-2473 1745-2481],
                   json['data']['logSearchEvent']['detectors']['standardIdentifiers'].first['details']['issns'])
      assert_nil(json['data']['logSearchEvent']['detectors']['standardIdentifiers'].first['details']['authors'])
    end
  end

  test 'search event query can return categorization details for searches that trip a detector' do
    post '/graphql', params: { query: '{
                                 logSearchEvent(sourceSystem: "timdex", searchTerm: "https://doi.org/10.1080/10509585.2015.1092083.") {
                                   categories {
                                     name
                                     confidence
                                   }
                                 }
                               }' }

    json = response.parsed_body

    assert_equal 'Transactional', json['data']['logSearchEvent']['categories'].first['name']
    assert_in_delta 0.95, json['data']['logSearchEvent']['categories'].first['confidence']
  end

  test 'term lookup query can return detected library of congress subject headings' do
    post '/graphql', params: { query: '{
                                 lookupTerm(searchTerm: "Geology -- Massachusetts") {
                                   detectors {
                                     lcsh
                                   }
                                 }
                               }' }

    json = response.parsed_body

    assert_equal('Geology -- Massachusetts',
                 json['data']['lookupTerm']['detectors']['lcsh'].first)
  end

  test 'term lookup query can return categorization details for searches that trip a detector' do
    post '/graphql', params: { query: '{
                                 lookupTerm(searchTerm: "10.1016/j.physio.2010.12.004") {
                                   categories {
                                     name
                                     confidence
                                   }
                                 }
                               }' }

    json = response.parsed_body

    assert_equal 'Transactional', json['data']['lookupTerm']['categories'].first['name']
    assert_in_delta 0.95, json['data']['lookupTerm']['categories'].first['confidence']
  end

  test 'primo searches use the preprocessor to extract actual keywords' do
    post '/graphql', params: { query: '{
                                 logSearchEvent(sourceSystem: "primo-test",
                                                searchTerm: "any,contains,Super cool search") {
                                   phrase
                                 }
                               }' }

    json = response.parsed_body

    assert_equal 'Super cool search', json['data']['logSearchEvent']['phrase']
  end

  test 'primo searches use the preprocessor and logs complex queries to a specific term' do
    post '/graphql', params: { query: '{
                                 logSearchEvent(sourceSystem: "primo-test",
                                                searchTerm: "any,contains,Super cool search;;any,contains,uh oh this is getting complicated") {
                                   phrase
                                 }
                               }' }

    json = response.parsed_body

    assert_equal 'unhandled complex primo query', json['data']['logSearchEvent']['phrase']
  end
end
