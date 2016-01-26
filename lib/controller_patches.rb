Rails.configuration.to_prepare do
    UserController.class_eval do
        require 'survey'

        def survey
        end

        # Reset the state of the survey so it can be answered again.
        # Handy for testing; not allowed in production.
        def survey_reset
            raise "Not allowed in production" if ENV["RAILS_ENV"] == "production"
            raise "Not logged in" if !@user
            @user.survey.allow_new_survey
            return redirect_to survey_url
        end
    end
end
