$(document).ready(function() {
  // Store last focused element to return focus when modal is closed
  let lastFocusedElement;

  // Add click event to all modal buttons
  $('.modal-button').on('click', function(e) {
    e.preventDefault();
    openModal($(this));
  });

  // Add keydown event to modal buttons for accessibility
  $('.modal-button').on('keydown', function(e) {
    // Check if Enter key is pressed
    if (e.key === 'Enter' || e.keyCode === 13) {
      e.preventDefault();
      openModal($(this));
    }
  });

  function openModal($button) {
    const $modalContent = $button.next('.modal-content');

    if ($modalContent.length) {
      // Store currently focused element
      lastFocusedElement = document.activeElement;

      $modalContent.removeClass('modal-hidden').attr('aria-hidden', 'false');

      // Make YouTube videos autoplay when modal opens
      $modalContent.find('iframe[src*="youtube"]').each(function() {
        let currentSrc = $(this).attr('src');

        // Check if the URL already has parameters
        if (currentSrc.indexOf('?') > 0) {
          // Already has parameters, add autoplay=1
          if (currentSrc.indexOf('autoplay=') === -1) {
            currentSrc += '&autoplay=1';
          }
        } else {
          // No parameters yet, add autoplay=1 as first parameter
          currentSrc += '?autoplay=1';
        }

        // Update the src to include autoplay
        $(this).attr('src', currentSrc);
      });

      // Create overlay
      $('body').append('<div class="modal-overlay"></div>');

      // Prevent page scrolling while modal is open
      $('body').css('overflow', 'hidden');

      // Adding fake elements so the keyboard navgation loop within the modal actually works
      // After adding Youtube videos inside the loop was not working anymore.
      // Insert hidden sentinel elements at the beginning and end of the modal
      // These help us detect when focus is about to leave the modal
      $modalContent.prepend('<div tabindex="0" class="focus-trap-start" style="position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0;"></div>');
      $modalContent.append('<div tabindex="0" class="focus-trap-end" style="position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0;"></div>');

      // Add event listeners to the sentinel elements
      $('.focus-trap-start').on('focus', function() {
        // When the start sentinel gets focus, move focus to the last focusable element
        const focusableElements = getFocusableElements($modalContent);
        if (focusableElements.length > 0) {
          focusableElements[focusableElements.length - 1].focus();
        }
      });

      $('.focus-trap-end').on('focus', function() {
        // When the end sentinel gets focus, move focus to the first focusable element
        const focusableElements = getFocusableElements($modalContent);
        if (focusableElements.length > 0) {
          focusableElements[0].focus();
        }
      });

      // Focus the first focusable element
      const focusableElements = getFocusableElements($modalContent);
      if (focusableElements.length > 0) {
        setTimeout(function() {
          focusableElements[0].focus();
        }, 100);
      }
    }
  }

  // Get all focusable elements in a container (returns DOM elements, not jQuery objects)
  function getFocusableElements($container) {
    return $container.find('a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"]):not(.focus-trap-start):not(.focus-trap-end), iframe[src*="youtube"]')
      .filter(':visible')
      .toArray();
  }

  // Close modal when clicking the close button
  $(document).on('click', '.modal-close', closeModal);

  // Close modal when clicking the overlay
  $(document).on('click', '.modal-overlay', closeModal);

  // Close modal when clicking outside the modal container but inside modal content
  $(document).on('click', '.modal-content', function(e) {
    // Only close if the click was directly on the modal-content element
    // (not on any of its children)
    if (e.target === this) {
      closeModal();
    }
  });

  // Close modal when pressing Escape key
  $(document).on('keydown', function(e) {
    if ((e.key === 'Escape' || e.keyCode === 27) && $('.modal-content[aria-hidden="false"]').length) {
      closeModal();
    }
  });

  function closeModal() {
    const $openModal = $('.modal-content[aria-hidden="false"]');
    if ($openModal.length) {
      // Find any YouTube iframes and stop playback
      $openModal.find('iframe[src*="youtube"]').each(function() {
        // This uses the YouTube iframe API to send a 'stopVideo' command
        this.contentWindow.postMessage('{"event":"command","func":"stopVideo","args":""}', '*');
      });

      // Remove sentinel elements
      $('.focus-trap-start, .focus-trap-end').remove();

      // Hide modal
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
});
