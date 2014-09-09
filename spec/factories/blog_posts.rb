# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :blog_post do
    title "MyString"
    post_date "2014-09-10"
    content "MyText"
  end
end
