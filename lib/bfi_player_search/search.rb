require 'uri'
require 'nokogiri'
require 'httpclient'

module BFIPlayerSearch
  class Search
    def search(query)
      r = response(query)
      films = film_fragments(r.body).map do |f|
        rp = ResultParser.new(f)
        {
          :title => rp.title,
          :url => rp.url,
          :image_url => rp.image_url,
          :year => rp.year,
          :certificate => rp.certificate,
          :free => rp.free?,
          :running_time_in_minutes => rp.running_time_in_minutes
        }
      end

      if films.empty? & !no_results_page?(r.body)
        raise BFIPlayerSearch::SearchResultsPageNotRecognised
      else
        films
      end
    end

    private
    def no_results_page?(page)
      page.include?('returned no results')
    end

    def response(query)
      HTTPClient.new.get('http://player.bfi.org.uk/search/', { 'q' => query })
    end

    def film_fragments(page)
      Nokogiri::HTML(page).css('#search-results article.film')
    end
  end
end
