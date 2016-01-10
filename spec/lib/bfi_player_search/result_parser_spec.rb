require 'spec_helper'

describe BFIPlayerSearch::ResultParser do
  let(:title) { 'The 39 Steps' }
  let(:year) { '1935' }
  let(:certificate) { 'U' }
  let(:url) { 'http://player.bfi.org.uk/film/watch-the-39-steps-1935/' }
  let(:image_url) { 'http://player.bfi.org.uk//media/images/stills/film/6865/0f6237fc6f0a145a72ffa136a7ad88f6-320x180.jpg' }
  let(:fragment) {
    Nokogiri::HTML::DocumentFragment.parse("<article class='film'>
      <a href='/film/watch-the-39-steps-1935/'>View The 39 Steps </a>
      <figure>
        <img src='//player.bfi.org.uk//media/images/stills/film/6865/0f6237fc6f0a145a72ffa136a7ad88f6-320x180.jpg'>
      </figure>
      <div class='film-preview'>
        <div class='price'></div>
        <h3 class='film-title'>
          <span class='title'>#{title} </span>
          <span class='film-year'>#{year}</span>
          <img class='certificate-image' alt='#{certificate}'>
        </h3>
      </div>
    </article>")
  }

  subject { BFIPlayerSearch::ResultParser.new(fragment) }

  describe '#title' do
    it { expect(subject.title).to eq(title) }
  end

  describe '#url' do
    it { expect(subject.url).to eq(url) }
  end

  describe '#image_url' do
    it { expect(subject.image_url).to eq(image_url) }
  end

  describe '#year' do
    it { expect(subject.year).to eq(year) }
  end

  describe '#certificate' do
    it { expect(subject.certificate).to eq(certificate) }

    context 'without certificate' do
      let(:fragment) {
        Nokogiri::HTML::DocumentFragment.parse("<article class='film'>
          <div class='film-preview'>
            <h3 class='film-title'>
            </h3>
          </div>
        </article>")
      }

      subject { BFIPlayerSearch::ResultParser.new(fragment) }

      it { expect(subject.certificate).to be_nil }
    end
  end

  describe '#free?' do
    it { expect(subject).to_not be_free }

    context 'when free' do
      let(:fragment) {
        Nokogiri::HTML::DocumentFragment.parse("<article class='film'>
          <div class='film-preview'>
            <div class='price'> Watch for free </div>
            <h3 class='film-title'>
            </h3>
          </div>
        </article>")
      }

      subject { BFIPlayerSearch::ResultParser.new(fragment) }

      it { expect(subject).to be_free }
    end
  end
end
