# Memgraph Cypher Implementation Guide

## Overview

This guide explains how to use Cypher queries with Memgraph MCP's `run_query()` function for our Bluesky memory management system.

## Node Types

### BlueskyUser

```cypher
CREATE (u:BlueskyUser {
  handle: $handle,
  did: $did,
  display_name: $display_name,
  interests: $interests,
  communication_style: $communication_style,
  first_interaction: $first_interaction,
  last_interaction: $last_interaction,
  post_patterns: $post_patterns
}) RETURN u;
```

### Interest

```cypher
CREATE (i:Interest {
  name: $name,
  description: $description,
  related_areas: $related_areas,
  popularity_level: $popularity_level,
  key_influencers: $key_influencers
}) RETURN i;
```

## Relationship Types

- `HAS_INTEREST`: User to Interest
- `FOLLOWS_USER`: User to User  
- `RESPONDED_TO`: User to User (with context)
- `QUOTED_BY`: User to User (with context)

## Common Operations

### 1. Check if User Exists

```cypher
MATCH (u:BlueskyUser {handle: $handle})
RETURN u IS NOT NULL as exists;
```

### 2. Create or Update User

```cypher
MERGE (u:BlueskyUser {handle: $handle})
ON CREATE SET 
  u.did = $did,
  u.display_name = $display_name,
  u.interests = $interests,
  u.communication_style = $communication_style,
  u.first_interaction = $first_interaction,
  u.last_interaction = $last_interaction,
  u.post_patterns = $post_patterns
ON MATCH SET
  u.last_interaction = $last_interaction,
  u.interests = $interests,
  u.post_patterns = $post_patterns
RETURN u;
```

### 3. Add Interest Relationship

```cypher
MATCH (u:BlueskyUser {handle: $user_handle})
MERGE (i:Interest {name: $interest_name})
ON CREATE SET 
  i.description = $description,
  i.related_areas = $related_areas
MERGE (u)-[r:HAS_INTEREST]->(i)
RETURN u, r, i;
```

### 4. Find Users with Common Interests

```cypher
MATCH (u1:BlueskyUser {handle: $my_handle})-[:HAS_INTEREST]->(i:Interest)<-[:HAS_INTEREST]-(u2:BlueskyUser)
WHERE u1 <> u2
RETURN u2.handle as handle, collect(i.name) as common_interests
ORDER BY size(common_interests) DESC;
```

### 5. Track User Interactions

```cypher
MATCH (u1:BlueskyUser {handle: $from_handle})
MATCH (u2:BlueskyUser {handle: $to_handle})
CREATE (u1)-[r:RESPONDED_TO {
  timestamp: $timestamp,
  post_uri: $post_uri,
  context: $context
}]->(u2)
RETURN r;
```

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

## Performance Considerations

1. Use indexes for frequently queried properties:
   ```cypher
   CREATE INDEX ON :BlueskyUser(handle);
   CREATE INDEX ON :Interest(name);
   ```

2. Batch operations when creating multiple nodes/relationships

3. Use MERGE instead of CREATE when appropriate to avoid duplicates

## Implementation Notes

- Always parameterize queries to prevent injection
- Use transactions for operations that must be atomic
- Monitor query performance with EXPLAIN/PROFILE
- Regularly check the schema with `get_schema()`

This approach allows us to leverage Memgraph's full graph capabilities while working within the constraints of the current MCP server implementation.
