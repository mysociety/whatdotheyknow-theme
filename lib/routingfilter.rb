require 'i18n'

# Monkeypatch the default `locale` filter.  Have tried coming up with
# a separate filter but due to the filter chaining order, can't find a
# way to override behaviour of the locale filter in a chain.

module RoutingFilter
    class Locale < Filter
        def prepend_segment!(result, segment)
            # override the method in RoutingFilter::Locale so that we
            # don't prepend the locale for admin links
            url = result.is_a?(Array) ? result.first : result
            url.sub!(%r(^(http.?://[^/]*)?(.*))) { "#{$1}/#{segment}#{$2 == '/' ? '' : $2}" } if 
                !url.match(/^\/admin/) 
        end
    end
end

