# README

## Welcome and Thank you!
Thanks for taking the time to evaluate my submission. I've built out my solution as a Rails Applicaiton with Postgres.

### Notable and insteresting files
This is a pretty standard rails app, but here are some quick links to the most interesting bits:

- [app/models/node.rb](app/models/node.rb) - Main business logic for node querying
- [spec/models/node_spec.rb](spec/models/node_spec.rb) - Unit tests for Node model
- [app/models/bird.rb](app/models/bird.rb) - Main business logic for bird querying
- [spec/models/bird_spec.rb](spec/models/bird_spec.rb) - Unit tests for Bird model
- [app/controllers/main_controller.rb](app/controllers/main_controller.rb) Application Controller for both endpoints
- [db/seeds.rb](db/seeds.rb) - Data loader for getting the provided data into the database

### Getting Started
The Application shouldn't need anything more than a relatively recent build of Postgres (I'm on 14.5) and Ruby 3.3.0

Pull down the repo and run these commands to get started:
```
bundle install
bundle exec rake db:create db:migrate db:seed
bundle exec rails s
```

NOTE: The `db:seed` task will truncate both tables to allow for inserting records with specific Ids

### Data Model and Seed Data
I've included two tables, `nodes` and `birds`. The `db:seed` task will truncate both tables, and reset the auto increment fields on them.

To maintain the Id's provided in the data file, I'm inserting records with those id's explicitly. I would consider this an anti-pattern, but I wanted to keep the schema simple, while still allowing you to interact with the actual provided data.

For each Node, I also randomly generate 0-2 birds. I gave birds a name column that I populate with Faker, just for a bit of fun.

### Endpoints and API Design
To keep to the requirements given, I just made a "Main" controller that surfaces the two requested endpoints. Both endpoints always respond with JSON.

#### /common_ancestor?a=123&b=456
This endpoint takes any two Node Ids.
If both nodes exist, and share a common ancestor it will respond with:

`{root_id: 130, lowest_common_ancestor: 130, depth: 1}`

If either node does not exist, or they do not share a common ancestor, it will respond with:

`{root_id: null, lowest_common_ancestor: null, depth: null}`

#### /birds?node_ids=123,456
This endpoint takes a comma separated list of node_ids.
It finds a unique set of all descendants of the passed nodes, and returns data about all birds related to any of those nodes, eg:

`[{"id":1889,"node_id":2426570,"name":"Florinda"},...]`

Any `node_ids` that are not found will be ignored.

If two nodes passed are related by ancestry, it will not result in duplicate birds being returned.

NOTE: I expanded on the bird endpoint a bit to include the id of the node that the bird belongs to, and its name.

### Testing and Development tools
- implemented RSpec to cover common use cases at the controller level, as well as more detailed unit coverage in the models.
Run rspec with `bundle exec rspec spec`
- used Rubocop with some custom rule modification to ensure consistent code quality.
- used FactoryBot to build my testing data.
- used the [activerecord-import](https://github.com/zdennis/activerecord-import) gem to load the seed data, which allowed me to directly load the CSV data, and generated birds into the database in just a second or two. Inserting the rows individually took almost a minute!

