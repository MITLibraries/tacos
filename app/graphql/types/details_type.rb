# frozen_string_literal: true

module Types
  class DetailsType < Types::BaseObject
    field :authors, [String]
    field :best_oa_location, String
    field :date, String
    field :doi, String
    field :issns, [String]
    field :journal_image, String
    field :journal_link, String
    field :journal_name, String
    field :link_resolver_url, String
    field :oa, Boolean
    field :oa_status, String
    field :pmid, String
    field :publisher, String
    field :title, String

    def issns
      @object[:journal_issns]&.split(',')
    end

    def authors
      @object[:authors]&.split(';')
    end
  end
end
