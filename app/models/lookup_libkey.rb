# frozen_string_literal: true

# LookupLibkey can take a DOI or PMID and return metadata, link resolver links, and journal browse links.
class LookupLibkey
  BASEURL = 'https://public-api.thirdiron.com/public/v1/libraries'

  # Info is the main entry point into the LookupLibkey Class.
  #
  # @param doi [String]
  # @param pmid [String]
  # @return [Hash] or nil
  def self.info(doi: nil, pmid: nil)
    return unless expected_env?

    if doi.present?
      external_url = construct_url(doi:)
      Rails.logger.debug(external_url)
      external_data = fetch(external_url)
      return if external_data == 'Error'

      extract_metadata(external_data)
    elsif pmid.present?
      external_url = construct_url(pmid:)
      Rails.logger.debug(external_url)

      external_data = fetch(external_url)
      return if external_data == 'Error'

      extract_metadata(external_data)
    else
      Rails.logger.error('No doi or pmid provided to LookupLibkey')
      nil
    end
  end

  # expected_env? confirms both required variables are set
  #
  # @return Boolean
  def self.expected_env?
    Rails.logger.error('No LIBKEY_KEY set') if libkey_key.nil?

    Rails.logger.error('No LIBKEY_ID set') if libkey_id.nil?

    libkey_id.present? && libkey_key.present?
  end

  # using method instead of constant to allow for mutating in testing without causing sporadic failures
  def self.libkey_key
    ENV.fetch('LIBKEY_KEY', nil)
  end

  # using method instead of constant to allow for mutating in testing without causing sporadic failures
  def self.libkey_id
    ENV.fetch('LIBKEY_ID', nil)
  end

  # extract_metadata maps data from the LibKey response to an internal hash
  #
  # @return Hash
  def self.extract_metadata(external_data)
    {
      title: external_data['data']['title'],
      authors: external_data['data']['authors'].gsub('; ', ';'),
      doi: external_data['data']['doi'],
      pmid: external_data['data']['pmid'],
      oa: external_data['data']['openAccess'],
      date: external_data['data']['date'],
      journal_name: external_data['included'].first['title'],
      journal_issns: external_data['included'].first['issn'],
      journal_image: external_data['included'].first['coverImageUrl'],
      journal_link: external_data['included'].first['browzineWebLink'],
      link_resolver_url: external_data['data']['bestIntegratorLink']['bestLink']
    }
  end

  # https://thirdiron.atlassian.net/wiki/spaces/BrowZineAPIDocs/pages/65929220/BrowZine+Public+API+Overview
  # https://thirdiron.atlassian.net/wiki/spaces/BrowZineAPIDocs/pages/65699928/Article+DOI+PMID+Lookup+Endpoint+LibKey
  # public/v1/libraries/:library_id/articles/doi/:article_doi?access_token=ffffffff-ffff-ffff-ffff-ffffffffffff
  # /public/v1/libraries/:library_id/articles/pmid/:article_pmid?access_token=ffffffff-ffff-ffff-ffff-ffffffffffff
  def self.construct_url(doi: nil, pmid: nil)
    if doi.present?
      "#{BASEURL}/#{libkey_id}/articles/doi/#{doi}?include=journal&access_token=#{libkey_key}"
    elsif pmid.present?
      "#{BASEURL}/#{libkey_id}/articles/pmid/#{pmid}?include=journal&access_token=#{libkey_key}"
    else
      Rails.logger.error('No PMID or DOI provided to LookupLibkey.url()')
      nil
    end
  end

  # Fetch performs the HTTP calls, parses JSON for successful requests.
  def self.fetch(url)
    resp = HTTP.headers(accept: 'application/json').get(url)
    if resp.status == 200
      JSON.parse(resp.to_s)
    else
      Rails.logger.debug do
        'Fact lookup error. DOI or PMID detected but LibKey returned no data or otherwise errored'
      end
      Rails.logger.debug { "Response status: #{resp.status}" }
      Rails.logger.debug { "URL: #{url}" }
      'Error'
    end
  end
end
