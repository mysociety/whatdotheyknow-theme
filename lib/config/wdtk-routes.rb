# Here you can override or add to the pages in the core website

Rails.application.routes.draw do
  get '/england' => redirect('/body?tag=england', status: 302)
  get '/london' => redirect('/body?tag=london', status: 302)
  get '/scotland' => redirect('/body?tag=scotland', status: 302)
  get '/cymru' => redirect('/cy/body?tag=wales', status: 302)
  get '/wales' => redirect('/body?tag=wales', status: 302)
  get '/ni' => redirect('/body?tag=ni', status: 302)
  get '/northern-ireland' => redirect('/body?tag=ni', status: 302)

  get '/help/report-a-data-breach' => 'help#report_a_data_breach',
      as: :help_report_a_data_breach
  post '/help/report-a-data-breach' => 'help#report_a_data_breach_handle_form_submission',
      as: :help_report_a_data_breach_handle_form_submission
  get '/help/report-a-data-breach/thank-you' => 'help#report_a_data_breach_thank_you',
      as: :help_report_a_data_breach_thank_you

  get "/donate" => redirect("https://www.mysociety.org/donate/support-whatdotheyknow-and-mysociety"),
      as: :donate_to_mysociety   

  get "/help/ico-guidance-for-authorities" => redirect("https://ico.org.uk/media/for-organisations/documents/2021/2618998/how-to-disclose-information-safely-20201224.pdf"),
      as: :ico_guidance

  get "/help/microsoft-hidden-data" => redirect("http://support.microsoft.com/en-us/office/remove-hidden-data-and-personal-information-by-inspecting-documents-presentations-or-workbooks-356b7b5d-77af-44fe-a07f-9aa4d085966f#ID0EBBD=Excel"),
      as: :excel_guidance      

  get "/help/ico-anonymisation-code" => redirect("https://ico.org.uk/media/1061/anonymisation-code.pdf"),
     as: :ico_anonymisation_code

  get "/how-have-you-used-wdtk" => redirect("https://survey.alchemer.com/s3/7276877/How-have-you-used-WDTK"),
     as: :how_have_you_used_wdtk

  get '/help/principles' => 'help#principles',
      as: :help_principles

  get '/help/house_rules' => 'help#house_rules',
      as: :help_house_rules

  get '/help/how' => 'help#how',
      as: :help_how

  get '/help/complaints' => 'help#complaints',
      as: :help_complaints

  get '/help/volunteers' => 'help#volunteers',
      as: :help_volunteers

  get '/help/beginners' => 'help#beginners',
      as: :help_beginners

  get '/help/ico_officers' => 'help#ico_officers',
      as: :help_ico_officers

  get '/help/glossary' => 'help#glossary',
      as: :help_glossary

  get '/help/environmental_information' => 'help#environmental_information',
      as: :help_environmental_information

  get '/help/accessing_information' => 'help#accessing_information',
      as: :help_accessing_information

  get '/help/exemptions' => 'help#exemptions',
      as: :help_exemptions

  get '/help/authority_performance_tracking' => 'help#authority_performance_tracking',
      as: :help_authority_performance_tracking

  get '/help/search_engines' => 'help#search_engines',
      as: :help_search_engines

  get '/help/about_foi' => 'help#about_foi',
      as: :help_about_foi

  get '/help/about_foisa' => 'help#about_foisa',
      as: :help_about_foisa

  get '/help/no_response' => 'help#no_response',
      as: :help_no_response

  get '/help/appeals' => 'help#appeals',
      as: :help_appeals

  get '/help/removing_information' => 'help#removing_information',
      as: :help_removing_information

  get '/help/books' => 'help#books',
      as: :help_books
end
