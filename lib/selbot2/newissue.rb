module Selbot2
  class NewIssue
    include Cinch::Plugin

    HELPS << [":newissue", "Link to create a new issue for Selenium"]
    HELPS << [":ci webdriver", "Link to create a new issue for a specific WebDriver"]

    CHROME = 'https://goo.gl/GLqBrm'.freeze
    GECKO = 'https://goo.gl/B81m26'.freeze
    MARIONETTE = 'https://goo.gl/qZembo'.freeze
    EDGE = 'https://goo.gl/IagI9v'.freeze
    SELENIUM = "#{Selbot2::REPO}/issues/new".freeze

    prefix Selbot2::PREFIX
    match /newissue\s?(\w*)/

    def execute(m, webdriver)
      webdriver = webdriver.strip if webdriver

      case webdriver
        when /chrome(driver)?/
          message = "Submit a new issue with Chromedriver -- #{CHROME}"
        when /gecko(driver)?/
          message = "Submit a new issue with Geckodriver -- #{GECKO}"
        when /marionet+e/
          message = "Submit a new issue with Marionette -- #{MARIONETTE}"
        when /edge(driver)?/
          message = "Submit a new issue with Microsoft (Edge) Webdriver -- #{EDGE}"
        else
          message = "Submit a new issue with the Selenium project -- #{SELENIUM}"
      end
      m.reply message
    end

  end # NewIssue
end # Selbot2