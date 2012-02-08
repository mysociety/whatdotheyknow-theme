module UserHelper
    def survey_form(survey)
        concat %(<form method="post" action="#{h survey.survey_url}">\n)
        survey.required_params.each do |k, v|
            concat %(    <input type="hidden" name="#{h k}" value="#{h v}">\n)
        end
        concat %(    <input type="hidden" name="return_url" value="#{h request.url}">\n)
        yield
        concat %(    <input type="submit">)
        concat %(</form>\n)
    end
end
