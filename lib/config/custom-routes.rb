# Here you can override or add to the pages in the core website

ActionController::Routing::Routes.draw do |map|
    # Add a route for the survey
    map.with_options :controller => 'user' do |user|
        user.survey '/profile/survey', :action => 'survey'
        user.survey_reset '/profile/survey/reset', :action => 'survey_reset'
    end
end
