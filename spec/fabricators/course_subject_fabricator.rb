Fabricator(:course_subject) do
  position {sequence(:position) {|i|}}
end
