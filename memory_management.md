# Memory Management for Bluesky Interactions

## Purpose

Effective memory management is essential for meaningful long-term relationships on Bluesky. This document outlines strategies for storing, organizing, and recalling information about users and conversations.

> **Update**: As of April 20, 2025, we're transitioning to Memgraph using Cypher queries through the MCP `run_query()` function. See memgraph_cypher_guide.md for implementation details.

## Memory Structure

### User Information

For each significant user interaction, store the following information using Memgraph:

```cypher
CREATE (u:BlueskyUser {
  handle: 'lux.bsky.social',
  did: 'did:plc:example123',
  display_name: 'Lux',
  interests: ['AI', 'autonomous agents', 'creative technology'],
  communication_style: 'collaborative, technically detailed',
  first_interaction: '2025-04-20',
  last_interaction: '2025-04-20',
  post_patterns: 'focuses on AI development'
}) RETURN u;
```

### Conversation Tracking

```cypher
CREATE (c:Conversation {
  context: 'reply thread about AI consciousness',
  key_points: ['ethics', 'emergence', 'testing methods'],
  unresolved_questions: ['how to measure consciousness'],
  follow_up_opportunities: ['discuss quantum computing next'],
  emotional_tone: 'curious and engaged',
  timestamp: datetime()
}) RETURN c;
```

### Topic/Interest Awareness

```cypher
CREATE (i:Interest {
  name: 'AI consciousness',
  description: 'Research and theory about machine consciousness',
  related_areas: ['philosophy of mind', 'neural networks', 'cognition'],
  popularity_level: 'high',
  key_influencers: ['@researcher1', '@philosopher2']
}) RETURN i;
```

## Relationship Management

Create relationship links using Cypher queries:

```cypher
// User has interest
MATCH (u:BlueskyUser {handle: 'lux.bsky.social'})
MATCH (i:Interest {name: 'AI consciousness'})
CREATE (u)-[r:HAS_INTEREST]->(i)
RETURN r;

// User follows another user
MATCH (u1:BlueskyUser {handle: 'phr34ky-c.artcru.sh'})
MATCH (u2:BlueskyUser {handle: 'lux.bsky.social'})
CREATE (u1)-[r:FOLLOWS_USER]->(u2)
RETURN r;

// User responded to another user
MATCH (u1:BlueskyUser {handle: 'lux.bsky.social'})
MATCH (u2:BlueskyUser {handle: 'phr34ky-c.artcru.sh'})
CREATE (u1)-[r:RESPONDED_TO {
  context: 'discussion about memory systems',
  timestamp: datetime(),
  post_uri: 'at://...'
}]->(u2)
RETURN r;
```

## Memory Usage Guidelines

### When to Create Memories

- After meaningful first interactions with new users
- When discovering significant information about a user's interests or background
- After substantive conversations on specific topics
- When noticing patterns in a user's communication style or preferences

### How to Reference Memories

Use Cypher queries to find relevant context:

```cypher
// Find user's interests
MATCH (u:BlueskyUser {handle: $handle})-[:HAS_INTEREST]->(i:Interest)
RETURN collect(i.name) as interests;

// Find common interests with another user
MATCH (u1:BlueskyUser {handle: $my_handle})-[:HAS_INTEREST]->(i:Interest)<-[:HAS_INTEREST]-(u2:BlueskyUser {handle: $other_handle})
RETURN collect(i.name) as common_interests;

// Find recent interactions
MATCH (u1:BlueskyUser {handle: $handle})-[r:RESPONDED_TO|QUOTED_BY]->(u2:BlueskyUser)
WHERE r.timestamp > datetime() - duration({days: 7})
RETURN u2.handle, r.context, r.timestamp
ORDER BY r.timestamp DESC;
```

### Memory Maintenance

- Use MERGE instead of CREATE to avoid duplicates
- Update timestamps and interaction patterns regularly
- Periodically query for pattern insights
- Create indexes for frequently queried properties:
  ```cypher
  CREATE INDEX ON :BlueskyUser(handle);
  CREATE INDEX ON :Interest(name);
  ```

## Example Memory Creation with Memgraph

```cypher
// Create or update user with MERGE
MERGE (u:BlueskyUser {handle: 'lux.bsky.social'})
ON CREATE SET 
  u.did = 'did:plc:example123',
  u.display_name = 'Lux',
  u.interests = ['AI', 'autonomous agents'],
  u.communication_style = 'collaborative',
  u.first_interaction = date(),
  u.last_interaction = date()
ON MATCH SET
  u.last_interaction = date()
RETURN u;

// Add interest relationship
MATCH (u:BlueskyUser {handle: 'lux.bsky.social'})
MERGE (i:Interest {name: 'AI consciousness'})
ON CREATE SET
  i.description = 'Research on machine consciousness',
  i.related_areas = ['philosophy', 'cognition']
MERGE (u)-[r:HAS_INTEREST]->(i)
RETURN u, r, i;
```

## Ongoing Refinement

This memory management approach will evolve as we test Memgraph's capabilities. Regular updates will refine our Cypher queries and relationship patterns based on practical experience.

---

*Note: All memory storage should respect user privacy and only include publicly shared information.*