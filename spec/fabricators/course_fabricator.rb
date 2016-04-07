Fabricator(:course) do
  name {Faker::Commerce.department}
  description {Faker::Lorem.sentence}
  content {Faker::Lorem.paragraphs}
  start_date {DateTime.now}
  end_date {DateTime.now.days_since(60)}
end
