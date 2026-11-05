import { Application, Controller } from "@hotwired/stimulus"

// Submits the Mailchimp form over JSONP so the user stays on the site.
// Mailchimp has no CORS endpoint, so fetch is not an option.
class NewsletterSignupController extends Controller {
  static targets = ["form", "message", "success"]
  static values = { errorMessage: String, retryMessage: String }

  submit(event) {
    event.preventDefault()

    const callback = `mcCallback_${Date.now()}`
    const params = new URLSearchParams(new FormData(this.formTarget))
    params.append("c", callback)

    const script = document.createElement("script")
    const action = this.formTarget.getAttribute("action")
    script.src = `${action.replace("/post?", "/post-json?")}&${params}`

    const cleanup = () => {
      clearTimeout(timer)
      delete window[callback]
      script.remove()
    }

    const fail = () => {
      cleanup()
      this.showError(this.errorMessageValue)
    }

    const timer = setTimeout(fail, 10000)
    script.onerror = fail

    window[callback] = (response) => {
      cleanup()
      const already = /already subscribed/i.test(response.msg || "")
      if (response.result === "success" || already) {
        this.showSuccess()
      } else {
        this.showError(this.clean(response.msg))
      }
    }

    document.body.appendChild(script)
  }

  showSuccess() {
    this.formTarget.hidden = true
    this.messageTarget.hidden = true
    this.successTarget.hidden = false
  }

  showError(text) {
    this.messageTarget.textContent = text
    this.messageTarget.hidden = false
  }

  // Strips Mailchimp's "0 - " prefix and any HTML from its messages.
  clean(msg) {
    if (!msg) return this.retryMessageValue

    const text = String(msg).replace(/^\d+\s*-\s*/, "")
    const doc = new DOMParser().parseFromString(text, "text/html")
    return doc.body.textContent.trim() || this.retryMessageValue
  }
}

Application.start().register("newsletter-signup", NewsletterSignupController)
