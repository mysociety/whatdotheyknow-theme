// Submits the Mailchimp form without leaving the site.

(function () {
  'use strict';

  // Find every newsletter sign-up form and prevent default behaviour.
  function init() {
    document.querySelectorAll('.js-newsletter-signup').forEach(function (container) {
      if (container.dataset.newsletterInit) return;
      container.dataset.newsletterInit = '1';
      var form = container.querySelector('form');
      if (!form) return;
      form.addEventListener('submit', function (e) {
        e.preventDefault();
        submit(form, container);
      });
    });
  }

  function submit(form, container) {
    var base = form.getAttribute('action').replace('/post?', '/post-json?');
    var params = new URLSearchParams(new FormData(form));
    var cb = 'mcCallback_' + Date.now();
    params.append('c', cb);

    var script = document.createElement('script');
    script.src = base + '&' + params.toString();

    var timer = setTimeout(function () {
      cleanup();
      showErrorMessage(container, 'Sorry, something went wrong. Please try again.');
    }, 10000);

    // Clean the JSONP request (timer, window callback, script tag).
    function cleanup() {
      clearTimeout(timer);
      try { delete window[cb]; } catch (e) { window[cb] = undefined; }
      if (script.parentNode) script.parentNode.removeChild(script);
    }

    window[cb] = function (res) {
      cleanup();
      var already = res.msg && /already subscribed/i.test(res.msg);
      if (res.result === 'success' || already) {
        showSuccess(container, form);
      } else {
        showErrorMessage(container, clean(res.msg));
      }
    };

    script.onerror = function () {
      cleanup();
      showErrorMessage(container, 'Sorry, something went wrong. Please try again.');
    };

    document.body.appendChild(script);
  }

  function showSuccess(container, form) {
    form.hidden = true;
    var msg = container.querySelector('.newsletter-signup__message');
    if (msg) msg.hidden = true;
    var ok = container.querySelector('.newsletter-signup__success');
    if (ok) ok.hidden = false;
  }

  function showErrorMessage(container, text) {
    var msg = container.querySelector('.newsletter-signup__message');
    if (!msg) return;
    msg.textContent = text;
    msg.hidden = false;
  }

  function clean(msg) {
  if (!msg) return 'Please try again.';
  // Replaces Mailchimp prefixes errors "0 - " and includes HTML.
  var text = String(msg).replace(/^\d+\s*-\s*/, '');
  var tmp = document.createElement('div');
  tmp.innerHTML = text;
  return (tmp.textContent || tmp.innerText || '').trim() || 'Please try again.';
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
