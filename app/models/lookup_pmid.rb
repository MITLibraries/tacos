# frozen_string_literal: true

class LookupPmid
  def info(pmid)
    xml = fetch(pmid)
    return if xml == 'Error'

    metadata = extract_metadata(xml)
    metadata[:pmid] = pmid
    metadata[:link_resolver_url] = link_resolver_url(metadata)

    if metadata.reject { |_k, v| v.empty? }.present?
      metadata
    else
      Rails.logger.debug("Fact lookup error. PMID #{pmid} detected but ncbi returned no data")
      nil
    end
  end

  def extract_metadata(xml)
    {
      title: xml.xpath('//ArticleTitle').text,
      journal_name: xml.xpath('//Journal/Title').text,
      journal_volume: xml.xpath('//Journal/JournalIssue/Volume').text,
      date: xml.xpath('//Journal/JournalIssue/PubDate/Year').text,
      doi: xml.xpath('//PubmedData/ArticleIdList/ArticleId[@IdType="doi"]').text
    }
  end

  def url(pmid)
    "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=#{pmid}&retmode=xml"
  end

  def fetch(pmid)
    resp = HTTP.headers(accept: 'application/xml').get(url(pmid))

    if resp.status == 200
      Nokogiri::XML(resp.to_s)
    else
      Rails.logger.debug("Fact lookup error. PMID #{pmid} detected but ncbi an error status")
      Rails.logger.debug("URL: #{url(pmid)}")
      'Error'
    end
  end

  def link_resolver_url(metadata)
    "#{ENV.fetch('LINKRESOLVER_BASEURL')}&rft.atitle=#{metadata[:title]}&rft.date=#{metadata[:date]}&rft.jtitle=#{metadata[:journal_name]}&rft_id=info:doi/#{metadata[:doi]}"
  end
end
