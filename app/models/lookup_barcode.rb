# frozen_string_literal: true

# LookupBarcode takes a 14-digit integer (flagged by a regex within the Detector::StandardIdentifier class) and consults
# the Primo API for the associated record. The structure of this class is pretty close to the other lookup models, with
# an info method being the only public method. If Primo finds a record for the submitted barcode, the class returns some
# metadata about the record, along with a link to the complete record using the discovery/fulldisplay path.
class LookupBarcode
  # info takes a barcode as an argument and returns associated metadata about that item, provided Primo is able to
  # locate it. If no record is found for any reason, the method returns nil.
  #
  # @note While the barcode argument is technically a string, in reality it should be a 14-digit integer in order to
  #       return anything meaningful.
  # @param barcode String
  # @return Hash or Nil
  def info(barcode)
    xml = fetch(barcode)

    return if xml == 'Error'

    metadata = extract_metadata(xml)

    if metadata.reject { |_k, v| v.empty? }.present?
      metadata[:barcode] = barcode
      metadata[:link_resolver_url] = link_resolver_url(metadata)
      metadata
    else
      Rails.logger.debug { "Barcode lookup error. Barcode #{barcode} detected by Primo returned no data" }
      nil
    end
  end

  private

  def extract_metadata(xml)
    {
      recordId: xml.xpath('//recordIdentifier').text,
      title: xml.xpath('//title').text,
      date: xml.xpath('//date').text,
      publisher: xml.xpath('//publisher').text,
      authors: xml.xpath('//contributor').text
    }
  end

  def url(barcode)
    "https://mit.alma.exlibrisgroup.com/view/sru/01MIT_INST?version=1.2&operation=searchRetrieve&recordSchema=dc&query=alma.all_for_ui=#{barcode}"
  end

  def fetch(barcode)
    resp = HTTP.headers(accept: 'application/xml').get(url(barcode))

    if resp.status == 200
      Nokogiri::XML(resp.to_s).remove_namespaces!
    else
      Rails.logger.debug do
        "Barcode lookup error. Barcode #{barcode} detected but Primo returned an error status"
      end
      Rails.logger.debug { "URL: #{url(barcode)}" }
      'Error'
    end
  end

  def link_resolver_url(metadata)
    "https://mit.primo.exlibrisgroup.com/discovery/fulldisplay?vid=01MIT_INST:MIT&docid=alma#{metadata[:recordId]}"
  end
end
