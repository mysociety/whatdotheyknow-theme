# -*- encoding : utf-8 -*-

# If defined, ALAVETELI_TEST_THEME will be loaded in
# config/initializers/theme_loader
ALAVETELI_TEST_THEME = 'whatdotheyknow-theme'
require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','..','spec','spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','..','spec','integration','alaveteli_dsl'))

describe 'creating a request with spam terms' do
  let(:user) { FactoryBot.create(:user) }
  let(:public_body) { FactoryBot.create(:public_body, name: 'example') }
  let(:user_session) { login(user) }
  let(:spammy_message) { 'potato is a lower case spam term' }

  before do
    File.write(Rails.root + 'tmp/spam_terms.txt', "Potato\n")
  end

  it 'redirects to home page if the user is not signed in' do
    visit new_request_to_body_path(url_name: public_body.url_name)
    fill_in 'Summary', with: 'Message with spam terms'
    fill_in 'Your request', with: spammy_message
    find_button('Preview your public request').click

    expect(page).to have_current_path(root_path)
  end

  it 'bans a signed in user and redirects to their profile page' do
    using_session(user_session) do
      visit new_request_to_body_path(url_name: public_body.url_name)
      fill_in 'Summary', with: 'Message with spam terms'
      fill_in 'Your request', with: spammy_message
      find_button('Preview your public request').click

      expect(user.reload).to be_banned
      expect(page).to have_current_path(show_user_path(user.url_name))
    end
  end
end
