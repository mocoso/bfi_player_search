require 'spec_helper'

describe 'A search' do
  context 'with zero results', :vcr do
    it { expect(BFIPlayerSearch::Search.new.search('qqqqqqqqqqqqqqqqq')).to be_empty }
  end

  context 'with some results', :vcr do
    subject { BFIPlayerSearch::Search.new.search('wild tales') }

    it { expect(subject).to_not be_empty }
    it { expect(subject.first[:title]).to eq 'Wild Tales' }
    it { expect(subject.first[:url]).to match(%r{^http://player.bfi.org.uk/film/watch-.*}) }
    it { expect(subject.first[:image_url]).to match(%r{^http://player.bfi.org.uk//media/images/stills/film/.*\.jpg}) }
    it { expect(subject.first[:free]).to be_falsey }
    it { expect(subject.first[:certificate]).to eq('15') }
  end

  context 'with unrecognised page format returned' do
    before do
      VCR.turn_off!

      stub_request(:get, 'http://player.bfi.org.uk/search/?q=girl').
        to_return(:body => '<html><body><h1>Not what you expected</h1></body></html>')
    end

    after do
      VCR.turn_on!
    end

    it do
      expect {
        BFIPlayerSearch::Search.new.search('girl') 
      }.to raise_error(BFIPlayerSearch::SearchResultsPageNotRecognised)
    end
  end
end
