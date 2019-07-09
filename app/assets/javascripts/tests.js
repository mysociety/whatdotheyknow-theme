(function($) {
  $(function () {
    window.cxVariation = cxApi.chooseVariation();
    if(window.cxVariation === 1){
      var $donate = $('.sidebar__donate-cta');
      var $link = $('.sidebar__donate-cta__button', $donate);
      var experimentHref = URI($link.attr('href')).removeSearch('utm_content').
        addSearch('utm_content', 'experiment_no_' + window.cxVariation).
        toString();
      $link.attr('href', experimentHref)

      $('.asktheeu-promo').replaceWith($donate)
    }

    $('.sidebar__donate-cta__button').on('click', function(e){
      if( typeof ga !== 'undefined' && ga.loaded ){
        e.preventDefault();
        var $link = $(this);
        ga('send', {
          hitType: 'event',
          eventCategory: 'sidebar__donate-cta',
          eventAction: 'click',
          eventLabel: document.title,
          hitCallback: function() {
            window.location.href = $link.attr('href');
          }
        });
      }
    });
  });
})(window.jQuery);


