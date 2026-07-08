require_relative '../spec_helper'
require 'integration/alaveteli_dsl'

RSpec.describe 'public body area maps' do
  describe 'the public body page' do
    it 'includes a map container for a body tagged with a MapIt area' do
      body = FactoryBot.create(:public_body, tag_string: 'mapit:163965')

      visit show_public_body_path(url_name: body.url_name)

      container = page.find('.js-authority-map', visible: :hidden)
      expect(container['data-area-urls']).to eq('["/map_areas/163965"]')
    end

    it 'includes every tagged MapIt area on the map' do
      body = FactoryBot.create(
        :public_body, tag_string: 'mapit:2227 mapit:2636'
      )

      visit show_public_body_path(url_name: body.url_name)

      container = page.find('.js-authority-map', visible: :hidden)
      expect(container['data-area-urls']).
        to eq('["/map_areas/2227","/map_areas/2636"]')
    end

    it 'does not include a map container for non-numeric mapit tags' do
      body = FactoryBot.create(:public_body, tag_string: 'mapit:not_an_id')

      visit show_public_body_path(url_name: body.url_name)

      expect(page).not_to have_css('.js-authority-map', visible: :all)
    end

    it 'does not include a map container for untagged bodies' do
      body = FactoryBot.create(:public_body)

      visit show_public_body_path(url_name: body.url_name)

      expect(page).not_to have_css('.js-authority-map', visible: :all)
    end
  end

  describe 'fetching an area boundary', type: :request do
    let(:geojson) { '{ "type": "MultiPolygon", "coordinates": [] }' }

    def stub_mapit(area_id, **options)
      stub_request(
        :get,
        "https://mapit.mysociety.org/area/#{area_id}.geojson" \
        '?simplify_tolerance=0.0001'
      ).to_return(**options)
    end

    it 'proxies the area GeoJSON from MapIt' do
      stub_mapit(163965, status: 200, body: geojson)

      get '/map_areas/163965'

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('application/json')
      expect(response.body).to eq(geojson)
    end

    it 'returns bad gateway when MapIt returns an error' do
      stub_mapit(163965, status: 500)

      get '/map_areas/163965'

      expect(response).to have_http_status(:bad_gateway)
    end

    it 'returns bad gateway when MapIt does not return JSON' do
      stub_mapit(163965, status: 200, body: '<html>Blocked</html>')

      get '/map_areas/163965'

      expect(response).to have_http_status(:bad_gateway)
    end

    it 'returns bad gateway when MapIt times out' do
      stub_request(
        :get,
        'https://mapit.mysociety.org/area/163965.geojson' \
        '?simplify_tolerance=0.0001'
      ).to_timeout

      get '/map_areas/163965'

      expect(response).to have_http_status(:bad_gateway)
    end

    it 'does not route non-numeric area ids' do
      expect { get '/map_areas/not_an_id' }.
        to raise_error(ApplicationController::RouteNotFound)
    end
  end
end
