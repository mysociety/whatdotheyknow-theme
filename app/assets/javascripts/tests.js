// https://support.google.com/optimize/answer/9059383
function gtag() { dataLayer.push(arguments); };

function donateButtonTextVariant(variant) {
  if (variant === '0') {
      $(document).ready(function(){
        $('.donate-cta__button').text('Donate now');
      });
  } else if (variant === '1') {
    $(document).ready(function(){
      $('.donate-cta__button').text('Donate £5 now');
    });
  } else if (variant === '2') {
    $(document).ready(function(){
      $('.donate-cta__button').text('Donate £10 now');
    });
  }
};

gtag('event', 'optimize.callback', {
  name: 'XinKUWDjTuK7Yxyo3ZBS4g',
  callback: donateButtonTextVariant
});

$(function(){
  // Record an event whenever the donation button is clicked.
  $('.donate-cta__button').on('click', function(){
    if( typeof ga !== 'undefined' && ga.loaded ){
      e.preventDefault();
      var href = $(this).attr('href');
      ga('send', {
        hitType: 'event',
        eventCategory: 'Request page donate button',
        eventAction: 'click',
        eventLabel: document.title,
        hitCallback: function() {
          window.location.href = href;
        }
      });
    }
  });
});
