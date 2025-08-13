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

      // Check if carousel is inside a modal, to avoid sizing issues with the width of the carousel items.
      this.$modalParent = this.$carousel.closest('.modal-content');
      if (this.$modalParent.length > 0) {
        this.isInModal = true;
        this.setupModalHandlers();
      }

      this.init();
    }

    setupModalHandlers() {
      // Handle modal close button clicks to prevent focus issues
      this.$modalParent.on('click', '.modal-close', () => {
        // Move focus away from close button before modal hides
        // Focus the modal parent temporarily
        this.$modalParent.focus();
      });

      // Also handle when modal is about to be hidden. This should prevents console warning like "Blocked aria-hidden on an element because its descendant retained focus"
      const self = this;
      const modalObserver = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
          if (mutation.type === 'attributes' && 
              (mutation.attributeName === 'aria-hidden' || mutation.attributeName === 'class')) {
            const $target = $(mutation.target);

            if ($target.attr('aria-hidden') === 'true' || $target.hasClass('modal-hidden')) {
              // Ensure no element inside has focus
              const $focused = $(':focus');
              if ($focused.length && $.contains($target[0], $focused[0])) {
                $focused.blur();
              }
            }
          }
        });
      });

      // Observe the modal for changes
      modalObserver.observe(this.$modalParent[0], {
        attributes: true,
        attributeFilter: ['aria-hidden', 'class']
      });
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
      
      // Keyboard navigation
      this.$carousel.on('keydown', (e) => this.handleKeyboard(e));
      
      // Touch/swipe support
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
    }
    
    updateAriaAttributes() {
      // Update aria-hidden on slides
      this.$items.each((index, item) => {
        const $item = $(item);
        const isVisible = index === this.currentIndex;
        
        // If we're in a modal, be more careful with aria-hidden
        if (this.isInModal) {
          // Never apply aria-hidden to slides in modals to avoid focus conflicts
          // Instead, use inert attribute if available, or just manage tabindex
          if ('inert' in $item[0]) {
            // Use inert for better handling (prevents focus and events)
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
      // Disable/enable buttons at boundaries
      this.$prevBtn.attr('aria-disabled', this.currentIndex === 0);
      this.$nextBtn.attr('aria-disabled', this.currentIndex === this.totalItems - 1);
    }
    
    announceSlideChange() {
      // Announce slide change to screen readers
      const message = `Slide ${this.currentIndex + 1} of ${this.totalItems}`;
      this.$announcement.text(message);
    }

    refresh() {
      this.goToSlide(this.currentIndex, false);
    }
  }

  function initCarousel(element) {
    const $el = $(element);
    // Check if already initialized
    if (!$el.data('carousel-initialized')) {
      const instance = new AccessibleCarousel(element);
      $el.data('carousel-instance', instance);
      $el.data('carousel-initialized', true);
    }
  }

  // Initialize carousels that are NOT in modals immediately
  $('.js-carousel').each(function() {
    const $carousel = $(this);
    const $modalParent = $carousel.closest('.modal-content');

    if ($modalParent.length === 0) {
      // Not in a modal, initialize immediately
      initCarousel(this);
    } else {
      // In a modal, mark for lazy initialization
      $carousel.attr('data-carousel-lazy', 'true');
    }
  });
  
  // Listen for modal visibility changes using MutationObserver
  const modalObserver = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      if (mutation.type === 'attributes') {
        const $target = $(mutation.target);
        
        // Check if this is a modal becoming visible
        if ($target.hasClass('modal-content') && 
            !$target.hasClass('modal-hidden') && 
            $target.attr('aria-hidden') === 'false') {
          
          // Find any uninitialized carousels inside
          $target.find('.js-carousel[data-carousel-lazy="true"]').each(function() {
            const $carousel = $(this);
            
            // Small delay to ensure modal is fully rendered
            setTimeout(() => {
              initCarousel(this);
              $carousel.attr('data-carousel-lazy', 'false');
            }, 100);
          });
        }
      }
    });
  });

  $('.modal-content').each(function() {
    modalObserver.observe(this, {
      attributes: true,
      attributeFilter: ['class', 'aria-hidden']
    });
  });

  $(document).on('modal:opened', function(e, $modalContent) {
    if ($modalContent) {
      $modalContent.find('.js-carousel').each(function() {
        if (!$(this).data('carousel-initialized')) {
          setTimeout(() => {
            initCarousel(this);
          }, 100);
        }
      });
    }
  });
});
