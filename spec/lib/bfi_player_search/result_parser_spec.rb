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

    context 'when it is unescaped' do
      let(:image_url) { 'http://player.bfi.org.uk//media/images/stills/film/1812/friendships%20flip-320x180.jpg' }
      let(:fragment) {
        Nokogiri::HTML::DocumentFragment.parse("<article class='film'>
          <figure>
            <img src='//player.bfi.org.uk//media/images/stills/film/1812/friendships flip-320x180.jpg'>
          </figure>
        </article>")
      }

      it { expect(subject.image_url).to eq(image_url) }
    end
  end

  describe '#year' do
    it { expect(subject.year).to eq(year) }

    context 'without year' do
      let(:fragment) {
        Nokogiri::HTML::DocumentFragment.parse("<article class='film'>
          <div class='film-preview'>
            <h3 class='film-title'>
            </h3>
          </div>
        </article>")
      }

      subject { BFIPlayerSearch::ResultParser.new(fragment) }

      it { expect(subject.year).to be_nil }
    end
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

  describe '#running_time_in_minutes' do
    context 'no running time given' do
      it { expect(subject.running_time_in_minutes).to be_nil }
    end

    context 'running time given' do
      let(:fragment) {
        Nokogiri::HTML::DocumentFragment.parse("<article class='film'>
          <div class='film-preview'>
            <p class='film-info metrics'>
              <span>95 mins</span>
              <span>United Kingdom</span>
              <span>Director. Andrew Haigh</span>
            </p>
          </div>
        </article>")
      }

      it { expect(subject.running_time_in_minutes).to eq(95) }
    end
  end

  describe '#director' do
    context 'no director given' do
      it { expect(subject.director).to be_nil }
    end

    context 'director given' do
      let(:fragment) {
        Nokogiri::HTML::DocumentFragment.parse("<article class='film'>
          <div class='film-preview'>
            <p class='film-info metrics'>
              <span>95 mins</span>
              <span>United Kingdom</span>
              <span>Director. Andrew Haigh</span>
            </p>
          </div>
        </article>")
      }

      it { expect(subject.director).to eq('Andrew Haigh') }
    end
  end
end
