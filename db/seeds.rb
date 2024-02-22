# frozen_string_literal: true

require 'csv'
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Rails.logger.debug 'Truncating Nodes and Birds Tables...'
ActiveRecord::Base.connection.execute('TRUNCATE TABLE nodes, birds RESTART IDENTITY;')

puts 'Loading nodes from csv file.'
node_rows = CSV.read('data/nodes.csv')
node_columns = node_rows.shift
Node.import(node_columns, node_rows, validate: false)

puts 'Generating up to two birds for each node.'
bird_columns = %w[name node_id]
bird_rows = []
node_rows.each do |(node_id, _)|
  [0, 1, 2].sample.times do
    bird_rows << [Faker::Name.unique.first_name, node_id]
  end
end

Bird.import(bird_columns, bird_rows, validate: false)

puts 'Done Loading nodes and Birds.'
puts "Total Nodes: #{Node.count} Total Birds: #{Bird.count}"
