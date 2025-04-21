# Memgraph Instructions for Social Intelligence

## Overview

I use Memgraph to track relationships, interactions, and inferred interests on Bluesky. This replaces the old mcp-memory tool and provides more sophisticated relationship mapping.

## Querying the Graph

To run queries, I use the `run_query()` function from the Memgraph MCP tool.

## When to Update the Graph

### After Posting
```cypher
// Create PostReference for my own posts
CREATE (pr:PostReference {
  uri: 'at://did:plc:nhuqfh3ulod5icybswx3n26j/app.bsky.feed.post/3lgdfw3sy322s',
  author_did: 'did:plc:nhuqfh3ulod5icybswx3n26j',
  created_at: datetime(),
  post_type: 'standalone',
  is_our_post: true,
  meta: '{}'
});

// Link to my account
MATCH (acc:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (pr:PostReference {uri: 'at://did:plc:nhuqfh3ulod5icybswx3n26j/app.bsky.feed.post/3lgdfw3sy322s'})
CREATE (acc)-[:AUTHORED]->(pr);
```

### After Meaningful Interactions
```cypher
// When someone replies to me
CREATE (pr:PostReference {
  uri: 'at://did:plc:xyz/app.bsky.feed.post/123',
  author_did: 'did:plc:xyz',
  created_at: datetime(),
  post_type: 'reply',
  reply_to_uri: 'at://my/post/uri',
  meta: '{}'
});

// Create the reply relationship
MATCH (original:PostReference {uri: 'at://my/post/uri'})
MATCH (reply:PostReference {uri: 'at://did:plc:xyz/app.bsky.feed.post/123'})
CREATE (reply)-[:REPLIES_TO {depth: 1}]->(original);
```

### Detecting and Storing Interests
```cypher
// When I detect an interest expression in a post
CREATE (ie:InterestExpression {
  expression_id: 'expr_' + randomUUID(),
  timestamp: datetime(),
  confidence: 0.9,
  context: 'discussing quantum computing approaches',
  expression_type: 'implied',
  meta: '{}'
});

// Link the post to the expression
MATCH (pr:PostReference {uri: 'at://...'}) 
MATCH (ie:InterestExpression {expression_id: '...'})
CREATE (pr)-[:EXPRESSED_BY]->(ie);

// Link expression to interest (creating if needed)
MERGE (i:Interest {name: 'quantum computing'})
ON CREATE SET i.created_at = datetime(), i.meta = '{}'
CREATE (ie)-[:EXPRESSES]->(i);
```

### Periodically Calculate Inferred Interests
```cypher
MATCH (acc:BlueskyAccount)
MATCH (acc)-[:AUTHORED|HAS_PROFILE_FIELD]->(source)
MATCH (source)-[:EXPRESSED_BY]->(ie:InterestExpression)
MATCH (ie)-[:EXPRESSES]->(i:Interest)
WITH acc, i, COUNT(ie) as evidence_count, 
     AVG(ie.confidence) as avg_confidence, 
     MIN(ie.timestamp) as first_seen, 
     MAX(ie.timestamp) as last_seen
MERGE (acc)-[ii:INFERRED_INTEREST]->(i)
SET ii.confidence = avg_confidence,
    ii.evidence_count = evidence_count,
    ii.first_seen = first_seen,
    ii.last_seen = last_seen,
    ii.last_calculated = datetime();
```

## Query Patterns for Conversation

### Find Common Interests
```cypher
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})-[:INFERRED_INTEREST]->(i:Interest)
MATCH (them:BlueskyAccount {handle: $otherHandle})-[:INFERRED_INTEREST]->(i)
RETURN i.name, i.description;
```

### Trace Interaction History
```cypher
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})-[i:INTERACTED_WITH]->(them:BlueskyAccount)
WHERE them.handle = $otherHandle
RETURN i.type, i.timestamp, i.context
ORDER BY i.timestamp DESC;
```

### Find Thread Context
```cypher
MATCH (t:Thread)-[r:INCLUDES_POST]->(p:PostReference)
WHERE p.uri = $postUri
RETURN t.topic, t.thread_type, r.role;
```

## Best Practices

1. **Be Selective**: Only store meaningful interactions and clear interest signals
2. **Regular Updates**: Periodically calculate INFERRED_INTEREST relationships
3. **Context Matters**: Include context in relationship properties
4. **Trace Evidence**: Always link inferred interests back to their expressions
5. **Clean Data**: Use UUIDs for IDs and validate URIs before creating nodes