/**
 * Carousel component
 *
 * USAGE EXAMPLE:
 *
 * <div class="js-carousel" role="region" aria-label="Featured content"
 *      aria-roledescription="carousel" carousel-current-slide="0">
 *   <div class="js-carousel__wrapper">
 *     <div class="carousel-item" js-carousel-order="1">Slide 1 content</div>
 *     <div class="carousel-item" js-carousel-order="2">Slide 2 content</div>
 *     <div class="carousel-item" js-carousel-order="3">Slide 3 content</div>
 *   </div>
 *   <button class="js-carousel-button-previous" aria-label="Previous slide">Previous</button>
 *   <button class="js-carousel-button-next" aria-label="Next slide">Next</button>
 *   <div class="js-carousel__announcement" aria-live="polite" aria-atomic="true"></div>
 * </div>
 *
 * The carousel-current-slide attribute updates dynamically as users navigate (0-indexed)
 */

document.addEventListener('DOMContentLoaded', function() {
    class AccessibleCarousel {
        constructor(element) {
            this.carousel = element;
            this.wrapper = element.querySelector('.js-carousel__wrapper');
            this.items = Array.from(element.querySelectorAll('[js-carousel-order]'));
            this.prevBtn = element.querySelector('.js-carousel-button-previous');
            this.nextBtn = element.querySelector('.js-carousel-button-next');
            this.announcement = element.querySelector('.js-carousel__announcement');

            this.currentIndex = 0;
            this.totalItems = this.items.length;
            this.isTransitioning = false;
            this.isInModal = false;

            // Check if carousel is inside a modal
            this.modalParent = element.closest('.modal-content');
            if (this.modalParent) {
                this.isInModal = true;
            }

            this.init();
        }

        init() {
            this.sortItemsByOrder();
            this.updateAriaAttributes();
            this.bindEvents();
            this.goToSlide(0, false);
        }

        sortItemsByOrder() {
            const sorted = this.items.sort((a, b) => {
                const orderA = parseInt(a.getAttribute('js-carousel-order'), 10);
                const orderB = parseInt(b.getAttribute('js-carousel-order'), 10);
                return orderA - orderB;
            });

            // Re-append items in sorted order
            sorted.forEach(item => {
                this.wrapper.appendChild(item);
            });

            this.items = sorted;
        }

        bindEvents() {
            this.prevBtn.addEventListener('click', () => this.previous());
            this.nextBtn.addEventListener('click', () => this.next());
            this.carousel.addEventListener('keydown', (e) => this.handleKeyboard(e));
            this.addSwipeSupport();
        }

        handleKeyboard(e) {
            switch(e.key) {
                case 'ArrowLeft':
                    e.preventDefault();
                    this.previous();
                    break;
                case 'ArrowRight':
                    e.preventDefault();
                    this.next();
                    break;
                case 'Home':
                    e.preventDefault();
                    this.goToSlide(0);
                    break;
                case 'End':
                    e.preventDefault();
                    this.goToSlide(this.totalItems - 1);
                    break;
            }
        }

        addSwipeSupport() {
            let startX = 0;
            let endX = 0;

            this.carousel.addEventListener('touchstart', (e) => {
                startX = e.touches[0].clientX;
            });

            this.carousel.addEventListener('touchend', (e) => {
                endX = e.changedTouches[0].clientX;
                const diff = startX - endX;

                if (Math.abs(diff) > 50) { // Minimum swipe distance
                    if (diff > 0) {
                        this.next();
                    } else {
                        this.previous();
                    }
                }
            });
        }

        previous() {
            if (this.currentIndex > 0) {
                this.goToSlide(this.currentIndex - 1);
            }
        }

        next() {
            if (this.currentIndex < this.totalItems - 1) {
                this.goToSlide(this.currentIndex + 1);
            }
        }

        goToSlide(index, animate = true) {
            if (this.isTransitioning || index < 0 || index >= this.totalItems) {
                return;
            }

            this.isTransitioning = true;
            this.currentIndex = index;

            const translateX = -100 * index;
            this.carousel.scrollTop = 0;

            if (animate) {
                this.wrapper.style.transform = `translateX(${translateX}%)`;

                // Wait for transition to complete
                setTimeout(() => {
                    this.isTransitioning = false;
                }, 500);
            } else {
                this.wrapper.style.transition = 'none';
                this.wrapper.style.transform = `translateX(${translateX}%)`;

                // Force reflow and re-enable transitions
                this.wrapper.offsetHeight;
                this.wrapper.style.transition = '';
                this.isTransitioning = false;
            }

            this.updateAriaAttributes();
            this.announceSlideChange();
            this.updateButtonStates();
            this.updateSlideAttribute();
        }

        updateAriaAttributes() {
            // Update aria-hidden on slides
            this.items.forEach((item, index) => {
                const isVisible = index === this.currentIndex;

                // If we're in a modal, be more careful with aria-hidden
                if (this.isInModal) {
                    // Use inert attribute if available
                    if ('inert' in item) {
                        item.inert = !isVisible;
                    }
                } else {
                    // Not in modal, use normal aria-hidden
                    item.setAttribute('aria-hidden', !isVisible);
                }

                // Update tabindex for focusable elements (excluding modal-close)
                const focusableElements = item.querySelectorAll('a, button, input, select, textarea, [tabindex]');
                focusableElements.forEach(el => {
                    if (!el.classList.contains('modal-close')) {
                        el.setAttribute('tabindex', isVisible ? '0' : '-1');
                    }
                });
            });
        }

        updateButtonStates() {
            const currentFocus = document.activeElement;

            if (this.currentIndex === 0) {
                this.prevBtn.style.display = 'none';
                this.prevBtn.setAttribute('aria-disabled', 'true');
            } else {
                this.prevBtn.style.display = '';
                this.prevBtn.setAttribute('aria-disabled', 'false');
            }

            if (this.currentIndex === this.totalItems - 1) {
                this.nextBtn.style.display = 'none';
                this.nextBtn.setAttribute('aria-disabled', 'true');
            } else {
                this.nextBtn.style.display = '';
                this.nextBtn.setAttribute('aria-disabled', 'false');
            }
        }

        announceSlideChange() {
            const message = `Slide ${this.currentIndex + 1} of ${this.totalItems}`;
            this.announcement.textContent = message;
        }

        updateSlideAttribute() {
            const isLastSlide = this.currentIndex === this.totalItems - 1;
            const slideValue = isLastSlide ? 'last-slide' : this.currentIndex;
            this.carousel.setAttribute('carousel-current-slide', slideValue);
        }

        recalculate() {
            const savedIndex = this.currentIndex;
            this.wrapper.style.transition = 'none';
            this.wrapper.style.transform = 'translateX(0)';
            this.wrapper.offsetHeight;
            this.goToSlide(savedIndex, false);
            requestAnimationFrame(() => {
                this.wrapper.style.transition = '';
            });
        }
    }

    // Helper function to check if element is truly visible
    function isElementVisible(element) {
        return element.offsetWidth > 0 &&
               element.offsetHeight > 0 &&
               getComputedStyle(element).visibility !== 'hidden';
    }

    function initCarousel(element) {
        // Check if already initialized
        if (!element.hasAttribute('data-carousel-initialized')) {
            const instance = new AccessibleCarousel(element);
            element.carouselInstance = instance;
            element.setAttribute('data-carousel-initialized', 'true');

            // Remove pending flag if it exists
            element.removeAttribute('data-carousel-pending');
        }
    }

    // Initialize carousels based on visibility
    const carousels = document.querySelectorAll('.js-carousel');
    carousels.forEach(carousel => {
        if (isElementVisible(carousel)) {
            // Carousel is visible now, initialize immediately
            initCarousel(carousel);
        } else {
            // Mark as pending initialization
            carousel.setAttribute('data-carousel-pending', 'true');
        }
    });

    // Expose initialization function globally for modal to call
    window.initPendingCarousels = function(container) {
        const pendingCarousels = container.querySelectorAll('.js-carousel[data-carousel-pending="true"]');
        pendingCarousels.forEach(carousel => {
            if (isElementVisible(carousel)) {
                initCarousel(carousel);
            }
        });
    };

    // Expose recalculate function globally for modal to call
    window.recalculateCarousels = function(container) {
        const initializedCarousels = container.querySelectorAll('.js-carousel[data-carousel-initialized="true"]');
        initializedCarousels.forEach(carousel => {
            if (carousel.carouselInstance && carousel.carouselInstance.recalculate) {
                carousel.carouselInstance.recalculate();
            }
        });
    };
});
