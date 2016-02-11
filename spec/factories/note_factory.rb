FactoryGirl.define do
  factory :note do
    stock
    body { FFaker::Lorem.paragraphs(5)[0] }
    title { FFaker::Lorem.sentences(1)[0] }
  end
end