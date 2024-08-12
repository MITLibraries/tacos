# frozen_string_literal: true

module Types
  class StandardIdentifiersType < Types::BaseObject
    field :details, DetailsType
    field :kind, String, null: false
    field :value, String, null: false

    # details does external lookups and should only be run if the fields
    # have been explicitly requested
    def details
      case @object[:kind]
      when :doi
        LookupDoi.new.info(@object[:value])
      when :isbn
        LookupIsbn.new.info(@object[:value])
      when :issn
        LookupIssn.new.info(@object[:value])
      when :pmid
        LookupPmid.new.info(@object[:value].split.last)
      end
    end
  end
end
