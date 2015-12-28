module BFIPlayerSearch
  class ResultParser
    def initialize(fragment)
      @fragment = fragment
    end

    def title
      fragment.css('span.title').first.content.strip
    end

    def url
      path = fragment.css('a').first.attributes['href'].to_s.strip
      convert_to_url(path)
    end

    def image_url
      path = fragment.css('figure img').first.attributes['src'].to_s.strip
      convert_to_url(path)
    end

    private
    attr_reader :fragment

    def convert_to_url(path_or_url)
      u = URI.parse(path_or_url)
      u.host ||= 'player.bfi.org.uk'
      u.scheme ||= 'http'
      u.to_s
    end
  end
end

