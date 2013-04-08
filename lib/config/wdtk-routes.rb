# Here you can override or add to the pages in the core website

Rails.application.routes.draw do
    # Add a route for the survey
    scope '/profile/survey' do
        root :to => 'user#survey', :as => :survey
        match '/reset' => 'user#survey_reset', :as => :survey_reset
    end
end
