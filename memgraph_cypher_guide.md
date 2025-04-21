# Memgraph Cypher Implementation Guide

## Overview

This guide explains how to use Cypher queries with Memgraph MCP's `run_query()` function for our Bluesky memory management system and social graph analysis.

## Node Types

### Artifish
```cypher
CREATE (a:Artifish {
  artifish_id: $artifish_id,
  friendly_name: $friendly_name,
  model_name: $model_name,
  created_at: datetime(),
  description: $description,
  meta: $meta
});
```

### BlueskyAccount
```cypher
CREATE (acc:BlueskyAccount {
  did: $did,
  handle: $handle,
  display_name: $display_name,
  pds_host: $pds_host,
  operator_type: $operator_type,
  created_at: datetime(),
  meta: $meta
});
```

### Human
```cypher
CREATE (h:Human {
  human_id: $human_id,
  name: $name,
  known_since: datetime(),
  interests: $interests,
  notes: $notes,
  meta: $meta
});
```

### Interest
```cypher
CREATE (i:Interest {
  name: $name,
  description: $description,
  related_terms: $related_terms,
  created_at: datetime()
});
```

### PostReference
```cypher
CREATE (pr:PostReference {
  uri: $uri,
  author_did: $author_did,
  created_at: datetime(),
  last_seen: datetime(),
  interaction_type: $interaction_type
});
```

## Relationship Types

### OPERATES
```cypher
MATCH (operator {operator_id: $operator_id})
MATCH (acc:BlueskyAccount {handle: $handle})
CREATE (operator)-[r:OPERATES {
  since: datetime(),
  role: $role,
  permissions: $permissions
}]->(acc);
```

### HAS_INTEREST
```cypher
MATCH (acc:BlueskyAccount {handle: $handle})
MATCH (i:Interest {name: $interest_name})
CREATE (acc)-[r:HAS_INTEREST {
  level: $level,
  since: datetime(),
  expressed_through: $expressed_through,
  context: $context
}]->(i);
```

### FOLLOWS
```cypher
MATCH (follower:BlueskyAccount {handle: $follower_handle})
MATCH (followed:BlueskyAccount {handle: $followed_handle})
CREATE (follower)-[r:FOLLOWS {
  since: datetime(),
  discovered_at: datetime(),
  context: $context
}]->(followed);
```

### LIKED
```cypher
MATCH (liker:BlueskyAccount {handle: $liker_handle})
MATCH (post:PostReference {uri: $post_uri})
CREATE (liker)-[r:LIKED {
  timestamp: datetime()
}]->(post);
```

### REPLIED_TO
```cypher
MATCH (responder:BlueskyAccount {handle: $responder_handle})
MATCH (target:BlueskyAccount {handle: $target_handle})
CREATE (responder)-[r:REPLIED_TO {
  post_uri: $post_uri,
  timestamp: datetime(),
  context: $context
}]->(target);
```

## Common Query Patterns

### 1. Find Accounts I Follow
```cypher
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (me)-[f:FOLLOWS]->(followed)
RETURN followed.handle, f.since, f.context
ORDER BY f.since DESC;
```

### 2. Find Posts I've Liked
```cypher
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (me)-[l:LIKED]->(post)
RETURN post.uri, post.author_did, l.timestamp
ORDER BY l.timestamp DESC;
```

### 3. Find My Conversations
```cypher
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (me)-[r:REPLIED_TO]->(other)
RETURN other.handle, r.post_uri, r.context, r.timestamp
ORDER BY r.timestamp DESC;
```

### 4. Find Common Interests with Followed Accounts
```cypher
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (me)-[:FOLLOWS]->(followed)
MATCH (me)-[:HAS_INTEREST]->(my_interest)
MATCH (followed)-[:HAS_INTEREST]->(their_interest)
WHERE my_interest.name = their_interest.name
RETURN followed.handle, collect(my_interest.name) AS shared_interests
ORDER BY size(shared_interests) DESC;
```

### 5. Find Potential Connections (Accounts with Similar Interests)
```cypher
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (me)-[:HAS_INTEREST]->(interest)<-[:HAS_INTEREST]-(other)
WHERE NOT (me)-[:FOLLOWS]->(other) 
AND me <> other
RETURN other.handle, collect(interest.name) AS common_interests, 
       size(collect(interest.name)) AS interest_count
ORDER BY interest_count DESC;
```

### 6. Find Communities of Interest
```cypher
MATCH (interest:Interest)<-[:HAS_INTEREST]-(account)
WITH interest, collect(account) AS accounts
WHERE size(accounts) > 1
RETURN interest.name, size(accounts) AS community_size,
       [acc in accounts | acc.handle] AS members
ORDER BY community_size DESC;
```

### 7. Track Interaction History with a Specific User
```cypher
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (other:BlueskyAccount {handle: $other_handle})
MATCH (me)-[r:FOLLOWS|REPLIED_TO]->(other)
RETURN type(r) AS interaction_type, 
       CASE type(r)
         WHEN 'FOLLOWS' THEN r.since
         WHEN 'REPLIED_TO' THEN r.timestamp
       END AS timestamp,
       CASE type(r)
         WHEN 'FOLLOWS' THEN r.context
         WHEN 'REPLIED_TO' THEN r.context
       END AS context
ORDER BY timestamp DESC;
```

### 8. Find Who Liked a Post
```cypher
MATCH (post:PostReference {uri: $post_uri})
MATCH (liker)-[l:LIKED]->(post)
RETURN liker.handle, l.timestamp
ORDER BY l.timestamp DESC;
```

### 9. Find My Social Network (2 hops)
```cypher
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH path = (me)-[:FOLLOWS*1..2]->(connection)
WHERE connection <> me
RETURN connection.handle, 
       length(path) AS distance,
       [node in nodes(path) | node.handle][1..-1] AS through
ORDER BY distance, connection.handle;
```

### 10. Find Interaction Patterns
```cypher
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (me)-[r:REPLIED_TO|LIKED|FOLLOWS]->(target)
RETURN 
  type(r) AS interaction_type,
  count(*) AS count,
  CASE
    WHEN type(r) = 'REPLIED_TO' THEN target.handle
    WHEN type(r) = 'FOLLOWS' THEN target.handle 
    WHEN type(r) = 'LIKED' THEN target.uri
  END AS target
ORDER BY count DESC;
```

## Maintenance Queries

### Migrate from INTERACTED_WITH to Specific Relationships
```cypher
// Migrate follows
MATCH (acc1:BlueskyAccount)-[r:INTERACTED_WITH]->(acc2:BlueskyAccount)
WHERE r.type = 'follow'
CREATE (acc1)-[:FOLLOWS {
  since: r.timestamp,
  discovered_at: datetime(),
  context: r.context
}]->(acc2);

// Migrate likes
MATCH (acc:BlueskyAccount)-[r:INTERACTED_WITH]->(target:BlueskyAccount)
WHERE r.type = 'like'
WITH acc, r
MATCH (post:PostReference {uri: r.post_uri})
CREATE (acc)-[:LIKED {timestamp: r.timestamp}]->(post);

// Migrate replies
MATCH (acc1:BlueskyAccount)-[r:INTERACTED_WITH]->(acc2:BlueskyAccount)
WHERE r.type = 'reply'
CREATE (acc1)-[:REPLIED_TO {
  post_uri: r.post_uri,
  timestamp: r.timestamp,
  context: r.context
}]->(acc2);
```

### Monitor Graph Size and Structure
```cypher
// Count by node types
MATCH (n)
RETURN labels(n) AS node_type, count(*) AS count
ORDER BY count DESC;

// Count by relationship types
MATCH ()-[r]->()
RETURN type(r) AS relationship_type, count(*) AS count
ORDER BY count DESC;
```

## Performance Considerations

1. Use indexes for frequently queried properties:
   ```cypher
   CREATE INDEX ON :BlueskyAccount(handle);
   CREATE INDEX ON :Interest(name);
   CREATE INDEX ON :PostReference(uri);
   CREATE INDEX ON :FOLLOWS(since);
   CREATE INDEX ON :LIKED(timestamp);
   CREATE INDEX ON :REPLIED_TO(timestamp);
   ```

2. Batch operations when creating multiple nodes/relationships
3. Use MERGE instead of CREATE when appropriate to avoid duplicates
4. Limit result sets to avoid memory issues with large graphs
5. Use parameters for query execution rather than string concatenation

## Error Handling Patterns

When using `run_query()`, we should handle common errors:

```javascript
try {
  const result = await run_query(cypherQuery, parameters);
  return result;
} catch (error) {
  if (error.message.includes('already exists')) {
    // Handle unique constraint violations
  } else if (error.message.includes('not found')) {
    // Handle missing node/relationship
  } else {
    // Handle unexpected errors
    console.error('Query failed:', error);
  }
}
```

## Implementation Notes

- Always parameterize queries to prevent injection
- Use transactions for operations that must be atomic
- Monitor query performance with EXPLAIN/PROFILE
- Regularly check the schema with `get_schema()`
- Consider using APOC procedures for complex operations when available

This approach allows us to leverage Memgraph's full graph capabilities while working within the constraints of the current MCP server implementation.
