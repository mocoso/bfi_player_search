module BFIPlayerSearch
  class ResultParser
    def initialize(fragment)
      @fragment = fragment
    end

    def title
      fragment.css('span.title').first.content.strip
    end

    def year
      if year_tag = fragment.css('span.film-year').first
        year_tag.content.strip
      end
    end

    def certificate
      if cert_tag = fragment.css('img.certificate-image').first
        cert_tag.attributes['alt'].to_s.strip
      end
    end

    def free?
      fragment.css('.price').first.content.include?('free')
    end

    def url
      path = fragment.css('a').first.attributes['href'].to_s.strip
      convert_to_url(path)
    end

    def image_url
      path = fragment.css('figure img').first.attributes['src'].to_s.strip
      convert_to_url(path)
    end

    def running_time_in_minutes
      match = fragment.css('.metrics span').map { |n| %r{(\d+) mins}.match(n.content) }.compact.first
      match && match[1].to_i
    end

    def director
      match = fragment.css('.metrics span').map { |n| %r{Director\. (.*)\Z}.match(n.content) }.compact.first
      match && match[1].strip
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

