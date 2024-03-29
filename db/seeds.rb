require 'csv'
puts 'Truncating Nodes and Birds Tables...'
ActiveRecord::Base.connection.execute('TRUNCATE TABLE nodes, birds RESTART IDENTITY;')

puts 'Loading Nodes from csv file.'
node_rows = CSV.read('data/nodes.csv')
node_columns = node_rows.shift
Node.import(node_columns, node_rows, validate: false)

puts 'Generating up to two Birds for each Node.'
bird_columns = %w[name node_id]
bird_rows = []
node_rows.each do |(node_id, _)|
  [0, 1, 2].sample.times do
    bird_rows << [Faker::Name.unique.first_name, node_id]
  end
end
Bird.import(bird_columns, bird_rows, validate: false)

puts "Done loading Nodes and Birds. Total Nodes: #{Node.count} Total Birds: #{Bird.count}"
