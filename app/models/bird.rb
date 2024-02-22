# frozen_string_literal: true

class Bird < ApplicationRecord
  belongs_to :node

  def self.for_all_descendants_of(node_ids)
    where(node_id: Node.all_descendant_ids(node_ids))
      .order(id: :asc)
      .pluck(:id, :node_id, :name)
      .map do |row|
        { id: row[0], node_id: row[1], name: row[2] }
      end
  end
end
