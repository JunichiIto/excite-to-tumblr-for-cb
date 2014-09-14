class ExciteBlogWriter
  attr_reader :browser, :wait

  def initialize
    @browser = Selenium::WebDriver.for :firefox
    @wait = Selenium::WebDriver::Wait.new(:timeout => 15)
  end

  def login
    info 'Logging in...'
    browser.get "http://www.excite.co.jp/?pname=blog&brand=xcit&lin=1&targeturl=http%3A%2F%2Fwww.exblog.jp%2F"

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

    info "Logged in."
  end

  def edit_content(excite_id, content)
    info "Editing #{excite_id}..."
    browser.get edit_url(excite_id)
    sleep 2 # 日付のselect boxが選択されるのを待つ

    input = wait.until {
      element = browser.find_element(:name, "content")
      element if element.displayed?
    }
    old_content = input.text
    input.clear
    input.send_keys content

    form = wait.until {
      element = browser.find_element(:name, "updateform")
      element if element.displayed?
    }

    form.find_element(:name, "submit_button").click
    sleep 4

    info "Edited."

    old_content
  end

  private

  def edit_url(excite_id)
    "http://www.exblog.jp/myblog/entry/edit/?eid=#{Settings.excite.eid}&srl=#{excite_id}"
  end

  def info(text)
    logger.info "[INFO] #{text}"
  end

  def logger
    Rails.logger
  end
end