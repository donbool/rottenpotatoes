# Add a declarative step here for populating the DB with movies.

Given(/the following movies exist/) do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    if movie["release_date"]
        movie["release_date"] = Date.strptime(movie["release_date"], "%d-%b-%Y")
      end
      Movie.create!(movie)
  end

end

Then(/(.*) seed movies should exist/) do |n_seeds|
  expect(Movie.count).to eq n_seeds.to_i
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then(/^I should see "(.*)" before "(.*)" in the movie list$/) do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  text =
    if page.has_css?('#movies')
      page.find('#movies').text
    else
      page.body
    end

  pos1 = text.index(e1)
  pos2 = text.index(e2)

end

# use gpt5 for help with this step definition
Then(/^I should see the movies in this order: (.+)$/) do |movie_list|
    titles = movie_list.split(/\s*,\s*/)
  
    text = if page.has_css?('#movies')
             page.find('#movies').text
           else
             page.body
           end
  
    last_idx = -1
    titles.each_with_index do |title, i|
      idx = text.index(title)
      expect(idx).not_to be_nil, %(Expected to find "#{title}" on the page)
      expect(idx).to be > last_idx, %(
        Expected "#{title}" to appear after "#{titles[i-1]}" in the output, but it did not
      ) unless i.zero?
      last_idx = idx
    end
  end

# Make it easier to express checking or unchecking several boxes at once
#  "When I check only the following ratings: PG, G, R"

When(/I check the following ratings: (.*)/) do |rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  ratings = rating_list.split(/\s*,\s*/)

  ratings.each do |r|
    step %{I check "#{r}" checkbox}
  end
end

Then(/^I should (not )?see the following movies: (.*)$/) do |no, movie_list|
  # Take a look at web_steps.rb Then /^(?:|I )should see "([^"]*)"$/
  titles = movie_list.split(/\s*,\s*/)
  titles.each do |title|
    if negation
      step %{I should not see "#{title}"}
    else
      step %{I should see "#{title}"}
    end
  end
end

Then(/^I should see all the movies$/) do
  # Make sure that all the movies in the app are visible in the table
  if page.has_css?('#movies [id^="movie_"]')
    rows = page.all('#movies [id^="movie_"]').size
  elsif page.has_css?('#movies .movie, #movies article, #movies li')
    rows = page.all('#movies .movie, #movies article, #movies li').size
  else
    rows = page.all('#movies a', text: 'Show this movie').size
  end

  expect(rows).to eq(Movie.count)
end

### Utility Steps Just for this assignment.

Then(/^debug$/) do
  # Use this to write "Then debug" in your scenario to open a console.
  require "byebug"
  byebug
  1 # intentionally force debugger context in this method
end

Then(/^debug javascript$/) do
  # Use this to write "Then debug" in your scenario to open a JS console
  page.driver.debugger
  1
end

Then(/complete the rest of of this scenario/) do
  # This shows you what a basic cucumber scenario looks like.
  # You should leave this block inside movie_steps, but replace
  # the line in your scenarios with the appropriate steps.
  raise "Remove this step from your .feature files"
end
