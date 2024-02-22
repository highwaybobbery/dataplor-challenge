class Node < ApplicationRecord
  belongs_to :parent, class_name: 'Node', optional: true
  has_many :children, class_name: 'Node', foreign_key: 'parent_id', dependent: :destroy, inverse_of: :parent
  has_many :birds, dependent: :destroy

  validates :parent_id, comparison: { other_than: :id }, allow_nil: true

  CommonAncestry = Struct.new(:root_id, :lowest_common_ancestor, :depth, keyword_init: true) do
    def add_ancestor(ancestor_id)
      # Initially nil
      self.depth ||= 0
      self.depth += 1

      # First encountered ancestor is root
      self.root_id ||= ancestor_id

      # Last encoutered ancestor is lowest common ancestor
      self.lowest_common_ancestor = ancestor_id
    end
  end

  def self.common_ancestor(node_a_id, node_b_id)
    common_ancestry = CommonAncestry.new(depth: nil, root_id: nil, lowest_common_ancestor: nil)
    # NOTE: To keep complexity of the sql down, we will execute two separate queries here.
    # This may also help in the future, as we can cash the restult of each individual query.
    node_a_ancestors = Node.find(node_a_id).ancestor_ids
    node_b_ancestors = Node.find(node_b_id).ancestor_ids

    # NOTE: the ancestors arrays will be mutated in place by this recursive function.
    find_lowest_common_ancestor(node_a_ancestors, node_b_ancestors, common_ancestry).to_h
  rescue ActiveRecord::RecordNotFound
    common_ancestry
  end

  def self.all_descendant_ids(node_ids)
    # NOTE: This query uses a CTE(Common Table Expression)
    # to recursively collect all descendants of the starting node in a single query
    # https://www.postgresql.org/docs/current/queries-with.html
    # While quite performant, we should definitely consider caching this data in an external cache (eg.redis)
    # Storing the descendants on the records would not work well, as adding a new child would require updating
    # all ancestor rows.
    sql = <<~SQL.squish
      WITH RECURSIVE descendants(id, depth) AS (
        SELECT id, 0 FROM nodes
        WHERE nodes.id IN (#{node_ids.join(', ')})
        UNION ALL
        SELECT nodes.id, depth + 1 FROM nodes
        JOIN descendants ON nodes.parent_id = descendants.id
      )
      SELECT DISTINCT id FROM descendants ORDER BY id ASC
    SQL
    connection.select_values(sql)
  end

  def ancestor_ids
    # NOTE: This query uses a CTE(Common Table Expression)
    # to recursively collect all ancestors of the starting node in a single query
    # https://www.postgresql.org/docs/current/queries-with.html
    # While quite performant, we should definitely consider caching this data either in an external cache (eg.redis),
    # or as an Array type column in the DB
    sql = <<~SQL.squish
      WITH RECURSIVE ancestors(id, parent_id, depth) AS (
        SELECT id, parent_id, 0 FROM nodes
        WHERE id = #{id}
        UNION ALL
        SELECT nodes.id, nodes.parent_id, depth + 1 FROM nodes
        JOIN ancestors ON nodes.id = ancestors.parent_id
        WHERE ancestors.parent_id IS NOT NULL
      )
      SELECT id FROM ancestors ORDER BY depth DESC
    SQL
    self.class.connection.select_values(sql)
  end

  def self.find_lowest_common_ancestor(node_a_ancestors, node_b_ancestors, data)
    return data if node_a_ancestors.empty? || node_b_ancestors.empty?

    # NOTE: we are mutating the ancestors arrays in place here.
    node_a_next = node_a_ancestors.shift
    node_b_next = node_b_ancestors.shift

    if node_a_next == node_b_next
      data.add_ancestor(node_a_next)
      find_lowest_common_ancestor(node_a_ancestors, node_b_ancestors, data)
    else
      data
    end
  end
end
