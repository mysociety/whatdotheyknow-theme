document.addEventListener('DOMContentLoaded', function() {
    const sidebarButton = document.querySelector('.sticky-sidebar-mobile-button');
    const sidebar = document.getElementById('table-of-contents');

    // SVG icons
    const HAMBURGER_ICON = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 17H21M3 12H21M3 7H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg> Table of contents';
    const CLOSE_ICON = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M18 6L6 18M6 6L18 18" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg> Table of contents';

    // Slide toggle
    function slideToggle(element, duration = 300, callback) {
        const isHidden = window.getComputedStyle(element).display === 'none';

        if (isHidden) {
            slideDown(element, duration, callback);
        } else {
            slideUp(element, duration, callback);
        }
    }

    function slideDown(element, duration = 300, callback) {
        element.style.removeProperty('display');
        let display = window.getComputedStyle(element).display;
        if (display === 'none') {
            display = 'block';
        }
        element.style.display = display;

        const height = element.offsetHeight;

        // Set initial state style
        element.style.overflow = 'hidden';
        element.style.height = 0;
        element.style.paddingTop = 0;
        element.style.paddingBottom = 0;
        element.style.marginTop = 0;
        element.style.marginBottom = 0;
        element.offsetHeight; // Force reflow

        // Transition
        element.style.boxSizing = 'border-box';
        element.style.transitionProperty = 'height, margin, padding';
        element.style.transitionDuration = duration + 'ms';
        element.style.height = height + 'px';
        element.style.removeProperty('padding-top');
        element.style.removeProperty('padding-bottom');
        element.style.removeProperty('margin-top');
        element.style.removeProperty('margin-bottom');

        // Clean up after transition
        setTimeout(() => {
            element.style.removeProperty('height');
            element.style.removeProperty('overflow');
            element.style.removeProperty('transition-duration');
            element.style.removeProperty('transition-property');
            if (callback) callback();
        }, duration);
    }

    function slideUp(element, duration = 300, callback) {
        // Set initial state
        element.style.transitionProperty = 'height, margin, padding';
        element.style.transitionDuration = duration + 'ms';
        element.style.boxSizing = 'border-box';
        element.style.height = element.offsetHeight + 'px';
        element.offsetHeight; // Force reflow

        // Start transition
        element.style.overflow = 'hidden';
        element.style.height = 0;
        element.style.paddingTop = 0;
        element.style.paddingBottom = 0;
        element.style.marginTop = 0;
        element.style.marginBottom = 0;

        // Clean up after transition
        setTimeout(() => {
            element.style.display = 'none';
            element.style.removeProperty('height');
            element.style.removeProperty('padding-top');
            element.style.removeProperty('padding-bottom');
            element.style.removeProperty('margin-top');
            element.style.removeProperty('margin-bottom');
            element.style.removeProperty('overflow');
            element.style.removeProperty('transition-duration');
            element.style.removeProperty('transition-property');
            if (callback) callback();
        }, duration);
    }

    function isVisible(element) {
        return element && window.getComputedStyle(element).display !== 'none';
    }

    // Display sticky sidebar on mobile
    if (sidebarButton && sidebar) {
        sidebarButton.addEventListener('click', function(event) {
            event.stopPropagation();

            const isExpanded = this.getAttribute('aria-expanded') === 'true';
            this.setAttribute('aria-expanded', !isExpanded);

            slideToggle(sidebar, 300, () => {
                if (isVisible(sidebar)) {
                    // Change to close icon
                    this.innerHTML = CLOSE_ICON;
                } else {
                    // Change back to hamburger icon
                    this.innerHTML = HAMBURGER_ICON;
                }
            });
        });

        // Prevent clicks inside the sidebar from closing it (except for links)
        sidebar.addEventListener('click', function(event) {
            // Check if the clicked element is a link
            if (event.target.tagName === 'A' || event.target.closest('a')) {
                // Close the sidebar when a link is clicked
                if (sidebarButton.getAttribute('aria-expanded') === 'true') {
                    slideUp(sidebar, 300);
                    sidebarButton.setAttribute('aria-expanded', 'false');
                    sidebarButton.innerHTML = HAMBURGER_ICON;
                }
            } else {
                // Prevent other clicks from closing the sidebar
                event.stopPropagation();
            }
        });

        // Close sidebar when clicking outside
        document.addEventListener('click', function() {
            if (sidebarButton.getAttribute('aria-expanded') === 'true' && isVisible(sidebar)) {
                slideUp(sidebar, 300);
                sidebarButton.setAttribute('aria-expanded', 'false');
                sidebarButton.innerHTML = HAMBURGER_ICON;
            }
        });
    }

    const smoothScrollLinks = document.querySelectorAll('.page-position-controller');

    smoothScrollLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();

            const targetId = this.getAttribute('href');
            const targetElement = document.querySelector(targetId);

            if (targetElement) {
                // Calculate the position
                const targetPosition = targetElement.getBoundingClientRect().top + window.pageYOffset;

                // Smooth scroll to target
                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });

                // Alternative for browsers that don't support smooth scrolling
                if (!('scrollBehavior' in document.documentElement.style)) {
                    smoothScrollTo(targetPosition, 400);
                }
            }
        });
    });

    // Fallback smooth scroll function for older browsers
    function smoothScrollTo(targetY, duration) {
        const startY = window.pageYOffset;
        const difference = targetY - startY;
        const startTime = performance.now();

        function step() {
            const currentTime = performance.now();
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);

            const easeInOut = progress < 0.5
                ? 2 * progress * progress
                : -1 + (4 - 2 * progress) * progress;

            window.scrollTo(0, startY + difference * easeInOut);

            if (progress < 1) {
                requestAnimationFrame(step);
            }
        }

        requestAnimationFrame(step);
    }
});
