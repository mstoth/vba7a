# Pin npm packages by running ./bin/importmap

pin "application"
pin "users"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "bootstrap" # @5.3.3
pin "@popperjs/core", to: "@popperjs--core.js" # @2.11.8
pin "jquery" # @3.7.1
pin "@hotwired/turbo-rails", to: "turbo.min.js"
