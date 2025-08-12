$(document).ready(function() {
  // Display stickyside bar on mobile
  $(".sticky-sidebar-mobile-button").click(function(event) {

    event.stopPropagation();

    const $sidebar = $("#table-of-contents");
    const $button = $(this);
    const isExpanded = $button.attr("aria-expanded") === "true";

    $button.attr("aria-expanded", !isExpanded);
    $sidebar.slideToggle(300, function() {
      if ($sidebar.is(":visible")) {
        // You could change the icon to an X here if you want
        $button.html('<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M18 6L6 18M6 6L18 18" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg> Table of contents');
      } else {
        // Change back to hamburger icon
        $button.html('<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 17H21M3 12H21M3 7H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg> Table of contents');
      }
    });
  });

  // Prevent clicks inside the sidebar from closing it
  $("#table-of-contents").click(function(event) {
    event.stopPropagation();
  });

  // Close sidebar when clicking outside
  $(document).click(function() {
    const $button = $(".sticky-sidebar-mobile-button");
    const $sidebar = $("#table-of-contents");

    if ($button.attr("aria-expanded") === "true" && $sidebar.is(":visible")) {
      $sidebar.slideUp(300);
      $button.attr("aria-expanded", "false");
      $button.html('<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 17H21M3 12H21M3 7H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg> Table of contents');
    }
  });
});

// Smooth scroll
$(document).ready(function() {
  $('.page-position-controller').on('click', function(e) {
    e.preventDefault();

    const target = $(this).attr('href');
    const $targetElement = $(target);

    if ($targetElement.length) {
      $('html, body').animate({
        scrollTop: $targetElement.offset().top
      }, 400);
    }
  });
});
