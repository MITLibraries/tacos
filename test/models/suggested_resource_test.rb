# frozen_string_literal: true

require 'test_helper'

class SuggestedResourceTest < ActiveSupport::TestCase
  test 'fingerprints are generated with new terms' do
    resource = {
      title: 'Our latest resource',
      url: 'https://example.org',
    }
    new_resource = SuggestedResource.create(resource)
    new_resource.terms.create(phrase: 'our latest resource')

    assert_equal 'latest our resource', new_resource.fingerprints.last.value
  end

  test 'can have multiple terms and fingerprints' do
    resource = {
      title: 'Our latest resource',
      url: 'https://example.org',
    }
    new_resource = SuggestedResource.create(resource)
    new_resource.terms.create(phrase: 'our latest resource')
    new_resource.terms.create(phrase: 'our other latest resource')

    assert_equal 2, new_resource.terms.count
    assert_equal 2, new_resource.fingerprints.count
  end

  test 'fingerprints update when terms do' do
    resource = suggested_resources('jstor')
    assert_not_equal resource.fingerprints.first.value, 'A brand new phrase'

    term = resource.terms.first
    term.phrase = 'This is a brand new phrase'
    term.save
    term.reload
    assert_equal 'a brand is new phrase this', resource.fingerprints.first.value
  end

  test 'destroying a resource preserves its dependents' do
    resource = suggested_resources('jstor')
    term = resource.terms.first
    fingerprint = resource.fingerprints.first
    resource.destroy
    assert term.present?
    assert fingerprint.present?
  end
end
