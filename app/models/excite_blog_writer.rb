class ExciteBlogWriter
  def test
    browser = Selenium::WebDriver.for :firefox
    browser.get "http://www.excite.co.jp/?pname=blog&brand=xcit&lin=1&targeturl=http%3A%2F%2Fwww.exblog.jp%2F"

    wait = Selenium::WebDriver::Wait.new(:timeout => 15)

    input = wait.until {
      element = browser.find_element(:name, "acctname")
      element if element.displayed?
    }
    input.send_keys(Settings.excite.id)

    input = wait.until {
      element = browser.find_element(:name, "passwd")
      element if element.displayed?
    }
    input.send_keys(Settings.excite.pass)

    form = wait.until {
      element = browser.find_element(:name, "login_form")
      element if element.displayed?
    }

    form.find_element(:name, "_action").click
    sleep 4

    browser.get "#{Settings.excite.edit_url}20178950"
    input = wait.until {
      element = browser.find_element(:name, "content")
      element if element.displayed?
    }
    content = input.text
    info content
    input.clear
    input.send_keys "TEST\nBye."

    browser.quit
  end

  def info(text)
    logger.info "[INFO] #{text}"
  end

  def logger
    Rails.logger
  end
end