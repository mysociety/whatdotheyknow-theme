document.addEventListener('DOMContentLoaded', function() {
    const container = document.querySelector('.js-read-container');
    const button = document.querySelector('.js-read-container-continue-button');

    // Create screen reader announcement
    const announcer = document.createElement('div');
    announcer.setAttribute('role', 'status');
    announcer.setAttribute('aria-live', 'polite');
    announcer.setAttribute('aria-atomic', 'true');
    announcer.classList.add('visually-hidden');
    document.body.appendChild(announcer);

    // Add helpful attributes to container
    container.setAttribute('role', 'region');
    container.setAttribute('aria-label', 'Terms and conditions text');
    container.setAttribute('tabindex', '0'); // Make focusable for keyboard users

    // Disable continue button
    button.classList.add('disabled');
    button.setAttribute('aria-disabled', 'true');
    button.setAttribute('aria-describedby', 'scroll-instruction');

    // Add instruction text for screen readers
    const instruction = document.createElement('span');
    instruction.setAttribute('id', 'scroll-instruction');
    instruction.classList.add('visually-hidden');
    instruction.textContent = 'Please read the entire text above before continuing';
    button.insertAdjacentElement('afterend', instruction);

    let hasScrolledToBottom = false;

    // Check scroll position
    function checkScroll() {
        if (!container) return;

        const scrollTop = container.scrollTop;
        const scrollHeight = container.scrollHeight;
        const clientHeight = container.clientHeight;

        // Check if scrolled to bottom (with 10px tolerance)
        if (scrollHeight - (scrollTop + clientHeight) <= 10) {
            if (!hasScrolledToBottom) {
                hasScrolledToBottom = true;

                // Enable the button
                button.classList.remove('disabled');
                button.removeAttribute('aria-disabled');
                button.removeAttribute('aria-describedby');
                button.classList.add('enabled-animation');

                // Announce to screen readers
                announcer.textContent = 'You have finished reading. The continue button is now enabled.';
            }
        }
    }

    // Scroll event listener with debouncing
    let scrollTimer;
    container.addEventListener('scroll', function() {
        clearTimeout(scrollTimer);
        scrollTimer = setTimeout(checkScroll, 50);
        checkScroll();
    });

    // Check initial state
    setTimeout(checkScroll, 100);

    // Prevent link click when disabled
    button.addEventListener('click', function(e) {
        if (this.classList.contains('disabled')) {
            e.preventDefault();

            // Announce to screen readers
            announcer.textContent = 'Please scroll to the bottom of the text before continuing.';

            // Focus the container so keyboard users know where to scroll
            container.focus();
            return false;
        }
    });

    // Navigate with keyboard
    container.addEventListener('keydown', function(e) {
        // Arrow keys, Page Up/Down, Home, End
        const scrollKeys = [33, 34, 35, 36, 38, 40];
        if (scrollKeys.includes(e.keyCode)) {
            setTimeout(checkScroll, 100);
        }
    });

    // Smooth scroll with mouse wheel
    container.addEventListener('wheel', function(e) {
        const scrollTop = this.scrollTop;
        const scrollHeight = this.scrollHeight;
        const clientHeight = this.clientHeight;
        const scrollAmount = e.deltaY * 0.3;

        // Check if we're at the top and scrolling up, or at the bottom and scrolling down
        const atTop = scrollTop === 0 && e.deltaY < 0;
        const atBottom = (scrollHeight - (scrollTop + clientHeight) <= 1) && e.deltaY > 0;

        // Only prevent default if we're not at the boundaries
        // OR if we're at a boundary but scrolling away from it
        if (!atTop && !atBottom) {
            e.preventDefault();
            this.scrollTop += scrollAmount;
        }
    });
});
