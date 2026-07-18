/**
 * Portfolio chat widget — calls the Cloudflare Worker chat API.
 *
 * Configure endpoint before deploy:
 *   window.PORTFOLIO_CHAT_CONFIG = { endpoint: 'https://your-worker.workers.dev/api/chat' };
 */
(function () {
  'use strict';

  var DEFAULT_CONFIG = {
    endpoint: '',
    maxMessageLength: 500,
    suggestedQuestions: [
      'What is Tobiah\'s current role?',
      'Tell me about the FORWARD senior design project.',
      'What research is Tobiah doing at UCF?',
      'What programming languages does Tobiah know?'
    ]
  };

  function getConfig() {
    return Object.assign({}, DEFAULT_CONFIG, window.PORTFOLIO_CHAT_CONFIG || {});
  }

  function createElement(tag, className, text) {
    var el = document.createElement(tag);
    if (className) el.className = className;
    if (text) el.textContent = text;
    return el;
  }

  function PortfolioChatWidget(config) {
    this.config = config;
    this.isOpen = false;
    this.isLoading = false;
    this.messages = [];
    this.mount();
  }

  PortfolioChatWidget.prototype.mount = function () {
    this.root = createElement('div', 'portfolio-chat');
    this.root.innerHTML =
      '<button type="button" class="portfolio-chat-toggle" aria-label="Open chat" aria-expanded="false">' +
        '<span class="portfolio-chat-toggle-icon" aria-hidden="true">💬</span>' +
        '<span class="portfolio-chat-toggle-label">Ask about me</span>' +
      '</button>' +
      '<div class="portfolio-chat-panel" role="dialog" aria-label="Portfolio assistant" hidden>' +
        '<header class="portfolio-chat-header">' +
          '<div><strong>Portfolio Assistant</strong><p>Ask about Tobiah\'s experience, projects, and skills.</p></div>' +
          '<button type="button" class="portfolio-chat-close" aria-label="Close chat">&times;</button>' +
        '</header>' +
        '<div class="portfolio-chat-messages" aria-live="polite"></div>' +
        '<div class="portfolio-chat-suggestions"></div>' +
        '<form class="portfolio-chat-form">' +
          '<input type="text" class="portfolio-chat-input" placeholder="Ask a question..." maxlength="' + this.config.maxMessageLength + '" autocomplete="off" />' +
          '<button type="submit" class="portfolio-chat-send">Send</button>' +
        '</form>' +
      '</div>';

    document.body.appendChild(this.root);

    this.panel = this.root.querySelector('.portfolio-chat-panel');
    this.messagesEl = this.root.querySelector('.portfolio-chat-messages');
    this.suggestionsEl = this.root.querySelector('.portfolio-chat-suggestions');
    this.form = this.root.querySelector('.portfolio-chat-form');
    this.input = this.root.querySelector('.portfolio-chat-input');
    this.toggleBtn = this.root.querySelector('.portfolio-chat-toggle');
    this.closeBtn = this.root.querySelector('.portfolio-chat-close');
    this.sendBtn = this.root.querySelector('.portfolio-chat-send');

    this.toggleBtn.addEventListener('click', this.toggle.bind(this));
    this.closeBtn.addEventListener('click', this.close.bind(this));
    this.form.addEventListener('submit', this.onSubmit.bind(this));

    this.renderSuggestions();
    this.addMessage('assistant', 'Hi! I can answer questions about Tobiah\'s resume, work at Lockheed Martin, research, and projects.');
  };

  PortfolioChatWidget.prototype.renderSuggestions = function () {
    var self = this;
    this.suggestionsEl.innerHTML = '';
    this.config.suggestedQuestions.forEach(function (question) {
      var btn = createElement('button', 'portfolio-chat-suggestion', question);
      btn.type = 'button';
      btn.addEventListener('click', function () {
        self.input.value = question;
        self.suggestionsEl.style.display = 'none';
        self.form.requestSubmit();
      });
      self.suggestionsEl.appendChild(btn);
    });
  };

  PortfolioChatWidget.prototype.toggle = function () {
    if (this.isOpen) {
      this.close();
    } else {
      this.open();
    }
  };

  PortfolioChatWidget.prototype.open = function () {
    this.isOpen = true;
    this.panel.hidden = false;
    this.toggleBtn.setAttribute('aria-expanded', 'true');
    this.input.focus();
  };

  PortfolioChatWidget.prototype.close = function () {
    this.isOpen = false;
    this.panel.hidden = true;
    this.toggleBtn.setAttribute('aria-expanded', 'false');
  };

  PortfolioChatWidget.prototype.addMessage = function (role, content) {
    this.messages.push({ role: role, content: content });
    var bubble = createElement('div', 'portfolio-chat-message portfolio-chat-message-' + role);
    bubble.textContent = content;
    this.messagesEl.appendChild(bubble);
    this.messagesEl.scrollTop = this.messagesEl.scrollHeight;
  };

  PortfolioChatWidget.prototype.setLoading = function (loading) {
    this.isLoading = loading;
    this.sendBtn.disabled = loading;
    this.input.disabled = loading;
  };

  PortfolioChatWidget.prototype.onSubmit = function (event) {
    event.preventDefault();
    if (this.isLoading) return;

    var message = this.input.value.trim();
    if (!message) return;

    this.input.value = '';
    this.addMessage('user', message);
    this.setLoading(true);

    var self = this;

    if (!this.config.endpoint || this.config.endpoint.includes('<YOUR_SUBDOMAIN>')) {
      setTimeout(function () {
        self.addMessage('assistant', 'The chat backend is not configured yet. Please check Tobiah\'s resume or contact him directly for now.');
        self.setLoading(false);
      }, 500);
      return;
    }

    fetch(this.config.endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: message })
    })
      .then(function (response) {
        return response.json().then(function (data) {
          if (!response.ok) {
            throw new Error(data.error || 'Request failed');
          }
          return data;
        });
      })
      .then(function (data) {
        self.addMessage('assistant', data.answer || 'No response received.');
      })
      .catch(function (error) {
        self.addMessage('assistant', 'Sorry, I could not reach the assistant right now. ' + error.message);
      })
      .finally(function () {
        self.setLoading(false);
      });
  };

  document.addEventListener('DOMContentLoaded', function () {
    new PortfolioChatWidget(getConfig());
  });
})();
