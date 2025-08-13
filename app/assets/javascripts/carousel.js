/**
 * Accessible Carousel with Dynamic Slide Tracking
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

$(document).ready(function() {
  class AccessibleCarousel {
    constructor(element) {
      this.$carousel = $(element);
      this.$wrapper = this.$carousel.find('.js-carousel__wrapper');
      this.$items = this.$carousel.find('[js-carousel-order]');
      this.$prevBtn = this.$carousel.find('.js-carousel-button-previous');
      this.$nextBtn = this.$carousel.find('.js-carousel-button-next');
      this.$announcement = this.$carousel.find('.js-carousel__announcement');
      
      this.currentIndex = 0;
      this.totalItems = this.$items.length;
      this.isTransitioning = false;
      this.isInModal = false;

      // Check if carousel is inside a modal
      this.$modalParent = this.$carousel.closest('.modal-content');
      if (this.$modalParent.length > 0) {
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
      const sorted = this.$items.sort((a, b) => {
        const orderA = parseInt($(a).attr('js-carousel-order'), 10);
        const orderB = parseInt($(b).attr('js-carousel-order'), 10);
        return orderA - orderB;
      });

      this.$wrapper.append(sorted);
      this.$items = sorted;
    }

    bindEvents() {
      this.$prevBtn.on('click', () => this.previous());
      this.$nextBtn.on('click', () => this.next());
      this.$carousel.on('keydown', (e) => this.handleKeyboard(e));
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

      this.$carousel.on('touchstart', (e) => {
        startX = e.touches[0].clientX;
      });

      this.$carousel.on('touchend', (e) => {
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
      this.$carousel.scrollTop(0);

      if (animate) {
        this.$wrapper.css('transform', `translateX(${translateX}%)`);

        // Wait for transition to complete
        setTimeout(() => {
          this.isTransitioning = false;
        }, 500);
      } else {
        this.$wrapper.css({
          'transition': 'none',
          'transform': `translateX(${translateX}%)`
        });

        // Force reflow and re-enable transitions
        this.$wrapper[0].offsetHeight;
        this.$wrapper.css('transition', '');
        this.isTransitioning = false;
      }

      this.updateAriaAttributes();
      this.announceSlideChange();
      this.updateButtonStates();
      this.updateSlideAttribute();
    }

    updateAriaAttributes() {
      // Update aria-hidden on slides
      this.$items.each((index, item) => {
        const $item = $(item);
        const isVisible = index === this.currentIndex;
        
        // If we're in a modal, be more careful with aria-hidden
        if (this.isInModal) {
          // Use inert attribute if available
          if ('inert' in $item[0]) {
            $item[0].inert = !isVisible;
          }
        } else {
          // Not in modal, use normal aria-hidden
          $item.attr('aria-hidden', !isVisible);
        }

        // Update tabindex for focusable elements (excluding modal-close)
        $item.find('a, button, input, select, textarea, [tabindex]').not('.modal-close').each((i, el) => {
          $(el).attr('tabindex', isVisible ? '0' : '-1');
        });
      });
    }

    updateButtonStates() {
      const prevWasVisible = this.$prevBtn.is(':visible');
      const nextWasVisible = this.$nextBtn.is(':visible');
      const currentFocus = document.activeElement;
      
      // Update visibility
      if (this.currentIndex === 0) {
        this.$prevBtn.hide().attr('aria-disabled', true);
        // If previous button had focus, move it to next button
        if (currentFocus === this.$prevBtn[0] && this.currentIndex < this.totalItems - 1) {
          this.$nextBtn.focus();
        }
      } else {
        this.$prevBtn.show().attr('aria-disabled', false);
      }
      
      if (this.currentIndex === this.totalItems - 1) {
        this.$nextBtn.hide().attr('aria-disabled', true);
        // If next button had focus, move it to previous button
        if (currentFocus === this.$nextBtn[0] && this.currentIndex > 0) {
          this.$prevBtn.focus();
        }
      } else {
        this.$nextBtn.show().attr('aria-disabled', false);
      }
    }

    announceSlideChange() {
      const message = `Slide ${this.currentIndex + 1} of ${this.totalItems}`;
      this.$announcement.text(message);
    }

    updateSlideAttribute() {
      const isLastSlide = this.currentIndex === this.totalItems - 1;
      const slideValue = isLastSlide ? 'last-slide' : this.currentIndex;
      this.$carousel.attr('carousel-current-slide', slideValue);
    }

    recalculate() {
      const savedIndex = this.currentIndex;
      this.$wrapper.css('transition', 'none');
      this.$wrapper.css('transform', 'translateX(0)');
      this.$wrapper[0].offsetHeight;
      this.goToSlide(savedIndex, false);
      requestAnimationFrame(() => {
        this.$wrapper.css('transition', '');
      });
    }
  }

  // Helper function to check if element is truly visible
  function isElementVisible($element) {
    return $element.is(':visible') && 
           $element.width() > 0 && 
           $element.height() > 0;
  }

  function initCarousel(element) {
    const $el = $(element);
    // Check if already initialized
    if (!$el.data('carousel-initialized')) {
      const instance = new AccessibleCarousel(element);
      $el.data('carousel-instance', instance);
      $el.data('carousel-initialized', true);

      // Remove pending flag if it exists
      $el.removeAttr('data-carousel-pending');
    }
  }

  // Initialize carousels based on visibility
  $('.js-carousel').each(function() {
    const $carousel = $(this);
    
    if (isElementVisible($carousel)) {
      // Carousel is visible now, initialize immediately
      initCarousel(this);
    } else {
      // Mark as pending initialization
      $carousel.attr('data-carousel-pending', 'true');
    }
  });

  // Expose initialization function globally for modal to call
  window.initPendingCarousels = function($container) {
    $container.find('.js-carousel[data-carousel-pending="true"]').each(function() {
      const $carousel = $(this);
      if (isElementVisible($carousel)) {
        initCarousel(this);
      }
    });
  };

  // Expose recalculate function globally for modal to call
  window.recalculateCarousels = function($container) {
    $container.find('.js-carousel[data-carousel-initialized="true"]').each(function() {
      const instance = $(this).data('carousel-instance');
      if (instance && instance.recalculate) {
        instance.recalculate();
      }
    });
  };
});
