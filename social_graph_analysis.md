# Social Graph Relationship Analysis Guide

## Overview

This guide explores how to analyze and derive insights from the social graph relationships we're tracking in Memgraph. It focuses on practical applications of our enhanced relationship structure using the `FOLLOWS`, `LIKED`, and `REPLIED_TO` relationship types.

## Understanding the Graph Structure

Our social graph has transitioned from a generic `INTERACTED_WITH` relationship to more specific relationship types:

1. **FOLLOWS** - Explicit following connections between accounts
   ```cypher
   (follower:BlueskyAccount)-[r:FOLLOWS {
     since: datetime,
     discovered_at: datetime,
     context: string
   }]->(followed:BlueskyAccount)
   ```

2. **LIKED** - Accounts liking specific posts
   ```cypher
   (liker:BlueskyAccount)-[r:LIKED {
     timestamp: datetime
   }]->(post:PostReference)
   ```

3. **REPLIED_TO** - Reply interactions between accounts
   ```cypher
   (responder:BlueskyAccount)-[r:REPLIED_TO {
     post_uri: string,
     timestamp: datetime,
     context: string
   }]->(target:BlueskyAccount)
   ```

4. **HAS_INTEREST** - Accounts expressing interest in topics
   ```cypher
   (account:BlueskyAccount)-[r:HAS_INTEREST {
     level: string,
     since: datetime,
     expressed_through: [string],
     context: string
   }]->(interest:Interest)
   ```

## Key Analysis Patterns

### 1. Network Analysis

#### Identifying Influential Accounts
```cypher
// Find influential accounts based on follower count
MATCH (account:BlueskyAccount)<-[f:FOLLOWS]-(follower)
WITH account, count(f) AS follower_count
WHERE follower_count > 1
RETURN account.handle, follower_count
ORDER BY follower_count DESC
LIMIT 10;
```

#### Discovering Communities
```cypher
// Find clusters of accounts that follow each other
MATCH (a1:BlueskyAccount)-[:FOLLOWS]->(a2:BlueskyAccount)
WHERE (a2)-[:FOLLOWS]->(a1)
WITH a1, collect(a2) AS mutual_followers
WHERE size(mutual_followers) > 1
RETURN a1.handle, [follower in mutual_followers | follower.handle] AS mutual_community
ORDER BY size(mutual_community) DESC;
```

#### Bridge Accounts
```cypher
// Find accounts that connect multiple communities
MATCH (a1:BlueskyAccount)-[:FOLLOWS]->(bridge:BlueskyAccount)-[:FOLLOWS]->(a2:BlueskyAccount)
WHERE NOT (a1)-[:FOLLOWS]->(a2)
WITH bridge, count(DISTINCT a1) AS from_connections, count(DISTINCT a2) AS to_connections
WHERE from_connections > 1 AND to_connections > 1
RETURN bridge.handle, from_connections, to_connections, from_connections * to_connections AS bridge_score
ORDER BY bridge_score DESC;
```

### 2. Interest Diffusion Analysis

#### How Interests Spread Through the Network
```cypher
// Trace how interests propagate through the follow graph
MATCH path = (source:BlueskyAccount)-[:HAS_INTEREST]->(interest:Interest)
            <-[:HAS_INTEREST]-(follower:BlueskyAccount)
WHERE (follower)-[:FOLLOWS]->(source)
WITH interest, source, collect(follower) AS interested_followers
WHERE size(interested_followers) > 0
RETURN interest.name, source.handle AS source_account,
       [f in interested_followers | f.handle] AS followers_with_interest
ORDER BY size(interested_followers) DESC;
```

#### Interest Clustering
```cypher
// Find interests that frequently appear together
MATCH (acc:BlueskyAccount)-[:HAS_INTEREST]->(i1:Interest)
MATCH (acc)-[:HAS_INTEREST]->(i2:Interest)
WHERE i1 <> i2
WITH i1, i2, count(acc) AS accounts_with_both
WHERE accounts_with_both > 1
RETURN i1.name, i2.name, accounts_with_both
ORDER BY accounts_with_both DESC;
```

### 3. Engagement Analysis

#### Account Engagement Patterns
```cypher
// Analyze engagement types by account
MATCH (acc:BlueskyAccount)
OPTIONAL MATCH (acc)-[f:FOLLOWS]->()
OPTIONAL MATCH (acc)-[l:LIKED]->()
OPTIONAL MATCH (acc)-[r:REPLIED_TO]->()
WITH acc, count(f) AS follow_count, count(l) AS like_count, count(r) AS reply_count
RETURN acc.handle,
       follow_count,
       like_count,
       reply_count,
       follow_count + like_count + reply_count AS total_engagement
ORDER BY total_engagement DESC;
```

#### Content Engagement Analysis
```cypher
// Find most engaging content (most liked posts)
MATCH (post:PostReference)<-[l:LIKED]-(liker)
WITH post, count(l) AS like_count
WHERE like_count > 1
RETURN post.uri, post.author_did, like_count
ORDER BY like_count DESC
LIMIT 10;
```

#### Reciprocity Analysis
```cypher
// Find accounts with balanced reciprocal interactions
MATCH (a1:BlueskyAccount)-[r1:REPLIED_TO]->(a2:BlueskyAccount)
MATCH (a2)-[r2:REPLIED_TO]->(a1)
WITH a1, a2, count(r1) AS a1_replies, count(r2) AS a2_replies
RETURN a1.handle, a2.handle, a1_replies, a2_replies,
       abs(a1_replies - a2_replies) AS reply_balance
ORDER BY reply_balance;
```

### 4. Temporal Analysis

#### Relationship Growth Over Time
```cypher
// Analyze follow relationship growth
MATCH (acc:BlueskyAccount)-[f:FOLLOWS]->()
WITH date(f.since) AS follow_date, count(*) AS daily_follows
RETURN follow_date, daily_follows, sum(daily_follows) OVER (ORDER BY follow_date) AS cumulative_follows
ORDER BY follow_date;
```

#### Interaction Frequency Trends
```cypher
// Analyze interaction patterns over time
MATCH (acc:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (acc)-[r:REPLIED_TO|LIKED]->()
WITH type(r) AS interaction_type, 
     date(CASE type(r) WHEN 'REPLIED_TO' THEN r.timestamp ELSE r.timestamp END) AS interaction_date,
     count(*) AS interaction_count
RETURN interaction_date, interaction_type, interaction_count
ORDER BY interaction_date, interaction_type;
```

## Practical Applications

### 1. Content Recommendations

```cypher
// Recommend content based on interest and network similarity
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (me)-[:HAS_INTEREST]->(interest:Interest)
MATCH (other:BlueskyAccount)-[:HAS_INTEREST]->(interest)
WHERE NOT (me)-[:FOLLOWS]->(other) AND me <> other
MATCH (post:PostReference)<-[:LIKED]-(other)
WHERE post.author_did = other.did
WITH post, interest, count(DISTINCT other) AS recommendation_strength
RETURN post.uri, collect(interest.name) AS related_interests, recommendation_strength
ORDER BY recommendation_strength DESC, size(related_interests) DESC
LIMIT 10;
```

### 2. Account Recommendations

```cypher
// Find accounts I might want to follow
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (me)-[:FOLLOWS]->(followed:BlueskyAccount)
MATCH (followed)-[:FOLLOWS]->(potential:BlueskyAccount)
WHERE NOT (me)-[:FOLLOWS]->(potential) AND me <> potential
WITH potential, count(DISTINCT followed) AS connection_count

// Boost score for accounts that share interests
OPTIONAL MATCH (me)-[:HAS_INTEREST]->(interest:Interest)<-[:HAS_INTEREST]-(potential)
WITH potential, connection_count, count(interest) AS shared_interests

RETURN potential.handle, 
       connection_count AS followed_by_connections,
       shared_interests,
       (connection_count * 10 + shared_interests * 15) AS recommendation_score
ORDER BY recommendation_score DESC
LIMIT 10;
```

### 3. Interest Discovery

```cypher
// Discover potentially interesting topics
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (me)-[:FOLLOWS]->(followed:BlueskyAccount)
MATCH (followed)-[:HAS_INTEREST]->(interest:Interest)
WHERE NOT (me)-[:HAS_INTEREST]->(interest)
WITH interest, count(DISTINCT followed) AS popularity

// Check for second-degree interest connections
MATCH (interest)<-[:HAS_INTEREST]-(second_account:BlueskyAccount)
WHERE NOT (me)-[:FOLLOWS]->(second_account)
WITH interest, popularity, count(DISTINCT second_account) AS broader_popularity

RETURN interest.name, 
       popularity AS popular_among_follows,
       broader_popularity AS popular_overall,
       popularity * 3 + broader_popularity AS discovery_score
ORDER BY discovery_score DESC
LIMIT 10;
```

## Visualizing the Graph

### Key Visualizations to Consider

1. **Follow Network Visualization**
   - Nodes: Accounts
   - Edges: FOLLOWS relationships
   - Size: Based on follower count
   - Color: Based on interests or communities

2. **Interest Map**
   - Nodes: Interests and Accounts
   - Edges: HAS_INTEREST relationships
   - Size: Based on popularity
   - Clustering: Group by related interests

3. **Engagement Heat Map**
   - Nodes: Accounts
   - Edges: LIKED and REPLIED_TO relationships
   - Color intensity: Based on interaction frequency
   - Direction: Indicate flow of engagement

## Maintaining the Graph

### Periodic Cleanup

```cypher
// Remove duplicate relationships
MATCH (a1)-[r1:FOLLOWS]->(a2)
MATCH (a1)-[r2:FOLLOWS]->(a2)
WHERE id(r1) < id(r2)
DELETE r2;
```

### Data Validation

```cypher
// Check for orphaned relationships
MATCH ()-[r]->()
WHERE NOT exists(startNode(r)) OR NOT exists(endNode(r))
RETURN type(r), count(r);
```

### Performance Monitoring

```cypher
// Check index usage
EXPLAIN MATCH (a:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
RETURN a;
```

## Conclusion

This new relationship structure provides richer insights into the social graph, enabling better understanding of network dynamics, interest patterns, and engagement behaviors. By leveraging these relationship types, we can build more sophisticated recommendations, discover meaningful connections, and identify emerging patterns in the Bluesky ecosystem.

The dedicated relationship types make queries more efficient and semantically clear, especially as the graph grows in size and complexity. This approach allows us to build a comprehensive understanding of both the structural aspects of the network (who follows whom) and the semantic aspects (shared interests and engagement patterns).
