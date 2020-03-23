if ( typeof dataLayer === 'object' && typeof gtag === 'undefined' ) {
  // https://support.google.com/optimize/answer/9059383
  function gtag() { dataLayer.push(arguments); };
}
