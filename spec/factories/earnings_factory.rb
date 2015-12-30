FactoryGirl.define do
  factory :earning do
    association :stock, factory: :stock
    q { rand(1..4) }
    y { rand(2009..2015) }
    report { rand(5.years).seconds.ago }
    eps { rand(-2.0..4.0) }
    revenue { rand (10..300) }
  end
end