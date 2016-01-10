bfi\_player\_search is a Ruby gem which provides a page scraped API for
searching the programmes available for streaming from the BFI player

# Installation

    $ gem install bfi_player_search

Or with Bundler in your Gemfile.

    gem 'bfi_player_search'

# Usage

    require 'bfi_player_search'

    bfi_search = BFIPlayerSearch::Search.new
    
    results = bfi_search.search('a most wanted man')
    
Where the results are an array containing a hash for each result. Each
result has `title`, `url` and `image_url`, `year`, `certificate` and
`free` keys.
