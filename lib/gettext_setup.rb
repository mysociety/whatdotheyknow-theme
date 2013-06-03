# Add a callback - to be executed before each request in development,
# and at startup in production - to plug in theme locale strings.
Rails.configuration.to_prepare do
    repos = [
        FastGettext::TranslationRepository.build('app', :path=>File.join(File.dirname(__FILE__), '..', 'locale-theme'), :type => :po),
        FastGettext::TranslationRepository.build('app', :path=>'locale', :type => :po)
    ]
    FastGettext.add_text_domain 'app', :type=>:chain, :chain=>repos
    FastGettext.default_text_domain = 'app'
end


