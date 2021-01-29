FactoryBot.define do
  factory :event do
    name { 'Test Event' }
    date { DateTime.now + 1.week }
    location { 'Test Location' }
    description { 'Test Description' }
    max_capacity { 5 }
    event_type_id { 1 }
    active { true }
    created_at { DateTime.now }
    updated_at { DateTime.now }
    created_by_uin { 123_456_789 }
  end
end
