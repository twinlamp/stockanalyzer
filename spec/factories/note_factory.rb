FactoryGirl.define do
  factory :note do
    stock
    body { FFaker::Lorem.paragraphs(5)[0] }
    title { FFaker::Lorem.sentences(1)[0] }
    happened_at { "2010-01-01".to_date + rand*(Date.today - "2010-01-01".to_date) }
  end
end