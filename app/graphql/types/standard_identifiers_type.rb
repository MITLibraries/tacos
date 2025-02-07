# frozen_string_literal: true

module Types
  class StandardIdentifiersType < Types::BaseObject
    description 'A detector for standard identifiers in search terms. Currently supported: Barcode, ISBN, ISSN, PMID, DOI'

    field :details, DetailsType, description: 'Additional information about the detected identifier(s)'
    field :kind, String, null: false, description: 'The type of identifier detected (one of Barcode, ISBN, ISSN, PMID, DOI)'
    field :value, String, null: false, description: 'The identifier detected in the search term'

    # details does external lookups and should only be run if the fields
    # have been explicitly requested
    def details
      case @object[:kind]
      when :barcode
        LookupBarcode.new.info(@object[:value])
      when :doi
        doi
      when :isbn
        LookupIsbn.new.info(@object[:value])
      when :issn
        LookupIssn.new.info(@object[:value])
      when :pmid
        pmid
      end
    end

    # doi handles determining which doi lookup method to use
    def doi
      if ENV.fetch('LIBKEY_DOI', false)
        LookupLibkey.info(doi: @object[:value])
      else
        LookupDoi.new.info(@object[:value])
      end
    end

    # pmid handles determining which pmid lookup method to use
    def pmid
      if ENV.fetch('LIBKEY_PMID', false)
        LookupLibkey.info(pmid: @object[:value])
      else
        LookupPmid.new.info(@object[:value].split.last)
      end
    end
  end
end
