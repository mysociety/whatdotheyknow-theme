require_relative '../spec_helper'
require 'integration/alaveteli_dsl'

RSpec.describe 'area landing page' do
  let!(:council) do
    FactoryBot.create(:public_body,
                      name: 'Isle of Wight Council',
                      tag_string: 'isle_of_wight local_council')
  end

  let!(:school) do
    FactoryBot.create(:public_body,
                      name: 'Medina College',
                      tag_string: 'isle_of_wight school')
  end

  let!(:unrelated_body) do
    FactoryBot.create(:public_body,
                      name: 'London Borough of Camden',
                      tag_string: 'london local_council')
  end

  before { Rails.cache.clear }

  it 'lists the authorities tagged with the area tag' do
    visit '/isle-of-wight'

    expect(page).to have_content('Freedom of Information in Isle of Wight')
    expect(page).to have_link('Isle of Wight Council')
    expect(page).to have_link('Medina College')
    expect(page).not_to have_content('London Borough of Camden')
  end

  it 'shows topline stats from the counter caches' do
    FactoryBot.create(:info_request, :successful, public_body: council)
    council.update_counter_cache

    visit '/isle-of-wight'

    expect(page).to have_content('2 public authorities')
    expect(page).to have_content('1 request made')
    expect(page).to have_content('1 successful request')
  end

  it 'filters authorities by category' do
    visit '/isle-of-wight'
    find(".area-page__categories a[href*='category=school']").click

    expect(page).to have_link('Medina College')
    expect(page).not_to have_link('Isle of Wight Council')
  end

  it 'filters authorities by search query' do
    visit '/isle-of-wight'
    fill_in 'public_body_query', with: 'Medina'
    click_button 'Search'

    expect(page).to have_link('Medina College')
    expect(page).not_to have_link('Isle of Wight Council')
  end

  it 'sorts authorities by number of requests' do
    FactoryBot.create(:info_request, public_body: school)
    school.update_counter_cache

    visit '/isle-of-wight?sort=requests'

    expect(page.body.index('Medina College')).
      to be < page.body.index('Isle of Wight Council')
  end

  it 'shows recent successful requests to authorities in the area' do
    successful = FactoryBot.create(:info_request, :successful,
                                   public_body: council)

    visit '/isle-of-wight'

    expect(page).to have_link(successful.title)
  end
end
