/**
* Combined Modal & Popup Script with Carousel

* USAGE EXAMPLES:

1.  Modal (triggered by button):

<button class="modal-button">Open Video</button>
<div class="modal-content modal-hidden" aria-hidden="true">
   <button class="modal-close">×</button>
   <div class="modal-container">
     <h2>Video Title</h2>
     <iframe src="https://www.youtube.com/embed/VIDEO_ID" frameborder="0" allowfullscreen></iframe>
   </div>
</div>

2. Auto-opening Popup:

<div class="modal-content modal-hidden" 
     aria-hidden="true"
     data-auto-open="true"
     data-open-delay="2000"
     data-click-outside-close="false">
  <button class="modal-close">×</button>
  <div class="modal-container">
    <h2>Welcome!</h2>
    <p>This popup appears automatically after 2 seconds.</p>
  </div>
</div>

DATA ATTRIBUTES:
- data-auto-open="true" - Makes it open automatically on page load
- data-open-delay="[milliseconds]" - Delay before auto-opening (optional)
- data-click-outside-close="false" - Prevents closing when clicking outside (optional)

*/

$(document).ready(function() {
  // Store last focused element to return focus when modal/popup is closed
  let lastFocusedElement;

  // Store opened popups to prevent re-opening
  const openedPopups = new Set();

  // Initialize all modals and popups
  function init() {
    setupModalButtons();
    setupAutoPopups();
  }

  // Setup traditional button-triggered modals
  function setupModalButtons() {
    $('.modal-button').on('click', function(e) {
      e.preventDefault();
      const $modalContent = $(this).next('.modal-content');
      openModal($modalContent);
    });

    $('.modal-button').on('keydown', function(e) {
      if (e.key === 'Enter' || e.keyCode === 13) {
        e.preventDefault();
        const $modalContent = $(this).next('.modal-content');
        openModal($modalContent);
      }
    });
  }

  // Setup auto-opening popups
  function setupAutoPopups() {
    $('.modal-content[data-auto-open="true"]').each(function() {
      const $popup = $(this);
      const popupId = $popup.attr('id') || Math.random().toString(36);
      
      // Check for delay
      const delay = parseInt($popup.data('open-delay')) || 0;
      
      setTimeout(function() {
        if (!openedPopups.has(popupId)) {
          openModal($popup);
          openedPopups.add(popupId);
        }
      }, delay);
    });
  }

  function openModal($modalContent) {
    if (!$modalContent || !$modalContent.length) return;

    if ($modalContent.attr('aria-hidden') === 'false') return;

    // Store currently focused element
    lastFocusedElement = document.activeElement;

    $modalContent.removeClass('modal-hidden').attr('aria-hidden', 'false');

    // Handle YouTube videos autoplay
    handleYouTubeAutoplay($modalContent);

    // Create overlay
    $('body').append('<div class="modal-overlay"></div>');

    // Prevent page scrolling while modal is open
    $('body').css('overflow', 'hidden');

    setupFocusTrap($modalContent);

    // Focus the first focusable element
    const focusableElements = getFocusableElements($modalContent);
    if (focusableElements.length > 0) {
      setTimeout(function() {
        focusableElements[0].focus();
      }, 100);
    }

    // Wait for CSS transitions to complete
    setTimeout(function() {
      // First, try to initialize any pending carousels
      if (window.initPendingCarousels) {
        window.initPendingCarousels($modalContent);
      }

      // Then recalculate any already-initialized carousels
      // (in case they were initialized while hidden)
      if (window.recalculateCarousels) {
        window.recalculateCarousels($modalContent);
      }
    }, 50); // Small delay to ensure modal transition is complete
  }

  function handleYouTubeAutoplay($modalContent) {
    $modalContent.find('iframe[src*="youtube"]').each(function() {
      let currentSrc = $(this).attr('src');
      
      if (currentSrc.indexOf('?') > 0) {
        if (currentSrc.indexOf('autoplay=') === -1) {
          currentSrc += '&autoplay=1';
        }
      } else {
        currentSrc += '?autoplay=1';
      }
      
      $(this).attr('src', currentSrc);
    });
  }

  function setupFocusTrap($modalContent) {
    // Add sentinel elements for focus trap
    $modalContent.prepend('<div tabindex="0" class="focus-trap-start" style="position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0;"></div>');
    $modalContent.append('<div tabindex="0" class="focus-trap-end" style="position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0;"></div>');

    $('.focus-trap-start').on('focus', function() {
      const focusableElements = getFocusableElements($modalContent);
      if (focusableElements.length > 0) {
        focusableElements[focusableElements.length - 1].focus();
      }
    });

    $('.focus-trap-end').on('focus', function() {
      const focusableElements = getFocusableElements($modalContent);
      if (focusableElements.length > 0) {
        focusableElements[0].focus();
      }
    });
  }

  function getFocusableElements($container) {
    return $container.find('a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"]):not(.focus-trap-start):not(.focus-trap-end), iframe[src*="youtube"]')
      .filter(':visible')
      .toArray();
  }

  // Close modal when clicking the close button
  $(document).on('click', '.modal-close', closeModal);

  // Close modal when clicking the overlay
  $(document).on('click', '.modal-overlay', function() {
    const $openModal = $('.modal-content[aria-hidden="false"]');
    // Check if click-outside-close is disabled
    if ($openModal.length && $openModal.data('click-outside-close') !== false) {
      closeModal();
    }
  });

  // Close modal when clicking outside the modal container
  $(document).on('click', '.modal-content', function(e) {
    // Check if click-outside-close is disabled
    const clickOutsideClose = $(this).data('click-outside-close') !== false;

    // Only close if clicking directly on modal-content and click-outside is enabled
    if (e.target === this && clickOutsideClose) {
      closeModal();
    }
  });

  $(document).on('keydown', function(e) {
    if ((e.key === 'Escape' || e.keyCode === 27) && $('.modal-content[aria-hidden="false"]').length) {
      closeModal();
    }
  });

  function closeModal() {
    const $openModal = $('.modal-content[aria-hidden="false"]');
    if ($openModal.length) {
      // Stop YouTube videos
      $openModal.find('iframe[src*="youtube"]').each(function() {
        this.contentWindow.postMessage('{"event":"command","func":"stopVideo","args":""}', '*');
      });

      // Remove sentinel elements
      $('.focus-trap-start, .focus-trap-end').remove();

      $openModal.addClass('modal-hidden').attr('aria-hidden', 'true');
      $('.modal-overlay').remove();
      $('body').css('overflow', '');

      // Return focus to the last focused element
      if (lastFocusedElement) {
        setTimeout(function() {
          lastFocusedElement.focus();
        }, 10);
      }
    }
  }


  init();

  window.ModalPopup = {
    open: function(selector) {
      const $element = $(selector);
      if ($element.length) {
        openModal($element);
      }
    },
    close: closeModal
  };
});
