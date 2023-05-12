require_relative '../spec_helper'
require 'integration/alaveteli_dsl'

RSpec.describe 'report a data breach page' do
  it 'displays a form to the visitor' do
    visit help_report_a_data_breach_path

    expect(page).to have_css('input[name="data_breach_report[url]"]')
    expect(page).to have_css('textarea[name="data_breach_report[message]"]')
    expect(page).to have_css('input[name="data_breach_report[contact_email]"]')
    expect(page).to have_css('input[name="data_breach_report[url]"]')
  end

  it 'validates the form' do
    visit help_report_a_data_breach_path

    click_button 'Send'

    expect(ActionMailer::Base.deliveries).to be_empty
    expect(page).to have_content('Please enter the URL of the page where the data breach occurred')
    expect(page).to have_content('Please describe the data breach')
    expect(page).to have_content('Please confirm whether you are reporting on behalf of the public body responsible for the data breach')
  end

  it 'user can submit the form and the result is emailed' do
    visit help_report_a_data_breach_path
    fill_in 'data_breach_report[url]', with: 'https://example.com'
    fill_in 'data_breach_report[message]', with: 'A data breach occurred'
    fill_in 'data_breach_report[contact_email]', with: 'test@example.com'
    choose 'data_breach_report[is_public_body]', option: 'true'
    check 'data_breach_report[special_category_or_criminal_offence_data]'
    click_button 'Send'

    expect(page).to have_content('Thank you for reporting a data breach')

    last_email = ActionMailer::Base.deliveries.last
    expect(last_email.from).to eq(['do-not-reply-to-this-address@localhost'])
    expect(last_email.to).to eq(['postmaster@localhost'])
    expect(last_email.subject).to eq('New data breach report')
    expect(last_email.body).to include('URL: https://example.com')
    expect(last_email.body).to include('Special category or criminal offence data: Yes')
    expect(last_email.body).to include('DPO email: test@example.com')
    expect(last_email.body).to include('Reporting on behalf of public body: Yes')
    expect(last_email.body).to include("Message:\nA data breach occurred")
  end
end
