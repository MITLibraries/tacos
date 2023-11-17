# frozen_string_literal: true

# LookupIssn assumes the ISSN being supplied has been validated prior to this Class being used.
# In this application, we only LookupIssns that have been detected in StandardIdentifiers which performs
# that validation for us. If extracting this logic to be used elsewhere, it is highly recommended to validate
# ISSNs before doing an external lookup.
class LookupIssn
  def info(issn)
    json = fetch(issn)
    return if json == 'Error'

    metadata = extract_metadata(json)
    metadata[:link_resolver_url] = openurl(issn)
    metadata
  end

  def extract_metadata(response)
    {
      journal_name: response['message']['title'],
      publisher: response['message']['publisher'],
      journal_issns: response['message']['ISSN'].join(',')
    }
  end

  def url(issn)
    "https://api.crossref.org/journals/#{issn}"
  end

  def fetch(issn)
    resp = HTTP.headers(accept: 'application/json').get(url(issn))
    if resp.status == 200
      JSON.parse(resp.to_s)
    else
      Rails.logger.debug("ISSN Lookup error. ISSN #{issn} detected but crossref returned no data")
      Rails.logger.debug("URL: #{url(issn)}")
      'Error'
    end
  end

  def openurl(issn)
    "#{ENV.fetch('LINKRESOLVER_BASEURL')}&rft.issn=#{issn}"
  end
end
