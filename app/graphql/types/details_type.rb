# frozen_string_literal: true

module Types
  class DetailsType < Types::BaseObject
    field :title, String
    field :authors, [String]
    field :date, String
    field :publisher, String
    field :oa, Boolean
    field :oa_status, String
    field :best_oa_location, String
    field :issns, [String]
    field :journal_name, String
    field :doi, String
    field :link_resolver_url, String

    def issns
      @object[:journal_issns]&.split(',')
    end

    def authors
      @object[:authors]&.split(',')
    end
  end
end
