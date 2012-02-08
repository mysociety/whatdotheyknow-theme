# Here you can override or add to the pages in the core website

require 'dispatcher'
Dispatcher.to_prepare do
    ActionController::Routing::Routes.draw do |map|
        # Add a route for the survey
        map.with_options :controller => 'user' do |user|
            user.survey '/profile/survey', :action => 'survey'
        end
    end
end
