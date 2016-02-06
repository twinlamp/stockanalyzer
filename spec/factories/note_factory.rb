FactoryGirl.define do
  factory :note do
    stock
    body { FFaker::Lorem.paragraphs(5, true) }
    title { FFaker::Lorem.sentences(1) }
  end
end