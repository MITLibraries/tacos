# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: 'Fetches an object given its ID.' do
      argument :id, ID, required: true, description: 'ID of the object.'
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [Types::NodeType, { null: true }], null: true,
                                                     description: 'Fetches a list of objects given a list of IDs.' do
      argument :ids, [ID], required: true, description: 'IDs of the objects.'
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :log_search_event, SearchEventType, null: false,
                                              description: 'Log a search and return information about it.' do
      argument :search_term, String, required: true
      argument :source_system, String, required: true
    end

    def log_search_event(search_term:, source_system:)
      term = Term.create_or_find_by!(phrase: search_term)
      term.search_events.create!(source: source_system)
    end
  end
end
