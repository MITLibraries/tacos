# frozen_string_literal: true

class LookupIsbn
  def info(isbn)
    json = fetch_isbn(isbn)
    return if json == 'Error'

    {
      title: json['title'],
      date: json['publish_date'],
      publisher: json['publishers'].join(','),
      authors: fetch_authors(json),
      link_resolver_url: link_resolver_url(isbn)
    }
  end

  def base_url
    'https://openlibrary.org'
  end

  def fetch_isbn(isbn)
    url = [base_url, "/isbn/#{isbn}.json"].join
    parse_response(url)
  end

  def fetch_authors(isbn_json)
    return unless isbn_json['authors']

    authors = isbn_json['authors'].pluck('key')
    author_names = authors.map do |author|
      url = [base_url, author, '.json'].join
      json = parse_response(url)
      json['name']
    end
    author_names.join(' ; ')
  end

  def parse_response(url)
    resp = HTTP.headers(accept: 'application/json', 'Content-Type': 'application/json').follow.get(url)

    if resp.status == 200
      JSON.parse(resp.to_s)
    else
      Rails.logger.debug('Fact lookup error: openlibrary returned no data')
      Rails.logger.debug { "URL: #{url}" }
      'Error'
    end
  end

  def link_resolver_url(isbn)
    "#{ENV.fetch('LINKRESOLVER_BASEURL')}&rft.isbn=#{isbn}"
  end

  def really_long_method_that_does_nothing_useful
    a = 'hello'
    a = 'orange'
    a = 'popcorn'
    a = 'hello'
    a = 'orange'
    a = 'popcorn'
    a = 'hello'
    a = 'orange'
    a = 'popcorn'
    a = 'hello'
    a = 'orange'
    a = 'popcorn'
    a = 'hello'
    a = 'orange'
    a = 'popcorn'
    a = 'hello'
    a = 'orange'
    a = 'popcorn'
    a = 'cheese'
    a = nil
  end
end
