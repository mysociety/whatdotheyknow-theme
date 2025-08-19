document.addEventListener('DOMContentLoaded', function() {
    const $container = $('.js-read-container');
    const $button = $('.js-read-container-continue-button');

    // Create screen reader announcement
    const $announcer = $('<div>')
        .attr('role', 'status')
        .attr('aria-live', 'polite')
        .attr('aria-atomic', 'true')
        .addClass('visually-hidden')
        .appendTo('body');

    // Add helpful attributes to container
    $container
        .attr('role', 'region')
        .attr('aria-label', 'Terms and conditions text')
        .attr('tabindex', '0'); // Make focusable for keyboard users

    // Disable continue button
    $button
        .addClass('disabled')
        .attr('aria-disabled', 'true')
        .attr('aria-describedby', 'scroll-instruction');

    // Add instruction text for screen readers
    $('<span>')
        .attr('id', 'scroll-instruction')
        .addClass('visually-hidden')
        .text('Please read the entire text above before continuing')
        .insertAfter($button);

    let hasScrolledToBottom = false;

    // Check scroll position
    function checkScroll() {
        const container = $container[0];
        if (!container) return;

        const scrollTop = container.scrollTop;
        const scrollHeight = container.scrollHeight;
        const clientHeight = container.clientHeight;

        // Check if scrolled to bottom (with 10px tolerance)
        if (scrollHeight - (scrollTop + clientHeight) <= 10) {
            if (!hasScrolledToBottom) {
                hasScrolledToBottom = true;

                // Enable the button
                $button
                    .removeClass('disabled')
                    .removeAttr('aria-disabled')
                    .removeAttr('aria-describedby')
                    .addClass('enabled-animation');

                // Announce to screen readers
                $announcer.text('You have finished reading. The continue button is now enabled.');
            }
        }
    }

    // Scroll event listener
    let scrollTimer;
    $container.on('scroll', function() {
        clearTimeout(scrollTimer);
        scrollTimer = setTimeout(checkScroll, 50);
        checkScroll();
    });

    // Check initial state
    setTimeout(checkScroll, 100);

    // Prevent link click when disabled
    $button.on('click', function(e) {
        if ($(this).hasClass('disabled')) {
            e.preventDefault();
            // Announce to screen readers
            $announcer.text('Please scroll to the bottom of the text before continuing.');
            // Focus the container so keyboard users know where to scroll
            $container.focus();
            return false;
        }
    });

    // Navigate with keyboard
    $container.on('keydown', function(e) {
        // Arrow keys, Page Up/Down, Home, End
        const scrollKeys = [33, 34, 35, 36, 38, 40];
        if (scrollKeys.includes(e.keyCode)) {
            setTimeout(checkScroll, 100);
        }
    });

    $container.on('wheel', function(e) {
        e.preventDefault();
        const scrollAmount = e.originalEvent.deltaY * 0.3;
        this.scrollTop += scrollAmount;
    });
});
