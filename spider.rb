require "watir"
require "watir-webdriver"
require 'xmlsimple'

def save_in_xmlfile(hash)
  File.open('SearchResults.xml', 'w') do |file|
    file.write XmlSimple.xml_out(hash) 
  end
end

def create_browser(start_link)
  browser = Watir::Browser.new
  browser.goto start_link
  browser
end

def get_jobs_amount(browser)
  title_search = "Search Results ("
  browser.spans.each do |span|
    inner_html = span.inner_html
    if inner_html[0, title_search.length] == title_search
      amount = inner_html[title_search.length, inner_html.length].to_i
      return amount
    end
  end
end

def goto_first_job_page(browser, amount)
  if amount > 0
    link_to_first_job = browser.span :class => 'titlelink'
    link_to_first_job.a.click
  end
end

def find_job_id(browser)
  browser.wait_until{browser.span(:id, "requisitionDescriptionInterface.reqContestNumberValue.row1").exists?}
  requisitionID = browser.span id: "requisitionDescriptionInterface.reqContestNumberValue.row1"
  requisitionIDtext = requisitionID.inner_html
  requisitionIDtext.to_i 
end

def find_job_description(browser)
  browser.wait_until{browser.divs(:class, "contentlinepanel")[1].exists?}
  divs_to_find_desctiption = browser.divs class: "contentlinepanel"
  browser.wait
  description = divs_to_find_desctiption[1].text
  sleep(1)
  description
end

def find_job_schedule(browser)
  browser.wait_until{browser.span(:class, "jobtype").exists?}
  schedule = browser.span class: "jobtype"
  scheduletext = schedule.inner_html
  scheduletext
end

def find_job_location(browser)
  browser.wait_until{browser.divs(:class, "contentlinepanel")[3].exists?}
  divs_to_find_location = browser.divs class: "contentlinepanel"
  location = divs_to_find_location[3].spans.last.inner_html
  location
end

def find_job_title(browser)
  browser.wait_until{browser.span(:id, "requisitionDescriptionInterface.reqTitleLinkAction.row1").exists?}
  title = browser.span id: "requisitionDescriptionInterface.reqTitleLinkAction.row1"
  title.inner_html
end

def make_job_hash(browser)
  hash = {}
  hash[:id] = find_job_id(browser)
  hash[:description] = find_job_description(browser) 
  hash[:location] = find_job_location(browser)
  hash[:schedule] = find_job_schedule(browser)
  hash
end

def goto_next_link(browser)
  browser.wait_until{browser.link(:text, 'Next').exists?}
  link_to_next_page = browser.link :text => 'Next'
  link_to_next_page.click
end

def get_information_about_jobs(browser, amount)
  hash = {}
  amount.times do
    hash[find_job_title(browser)] = make_job_hash(browser) 
    goto_next_link(browser)
  end
  hash
end

browser = create_browser('https://abseagle.taleo.net/careersection/ex/jobsearch.ftl?lang=en&portal=101430233')
begin
  jobs_amount = get_jobs_amount(browser)
  goto_first_job_page(browser, jobs_amount)
  jobs_hash = get_information_about_jobs(browser, jobs_amount)
  save_in_xmlfile(jobs_hash)
ensure
  browser.close
end

