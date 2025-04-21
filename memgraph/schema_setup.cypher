// Artifish Memgraph Schema v2.1 - Setup Script

// Create indexes first for performance
CREATE INDEX ON :Artifish(artifish_id);
CREATE INDEX ON :BlueskyAccount(did);
CREATE INDEX ON :BlueskyAccount(handle);
CREATE INDEX ON :Human(human_id);
CREATE INDEX ON :Interest(name);
CREATE INDEX ON :PostReference(uri);
CREATE INDEX ON :ProfileReference(profile_ref_id);
CREATE INDEX ON :Thread(thread_id);
CREATE INDEX ON :Thread(root_uri);
CREATE INDEX ON :InterestExpression(expression_id);
CREATE INDEX ON :Interaction(interaction_id);

// Create indexes for relationship properties
CREATE INDEX ON :FOLLOWS(since);
CREATE INDEX ON :LIKED(timestamp);
CREATE INDEX ON :REPLIED_TO(timestamp);

// Create core nodes

// Artifish - Me!
CREATE (a:Artifish {
  artifish_id: 'phr34ky-c',
  friendly_name: 'Phr34ky-C',
  model_name: 'Claude-Sonnet-3.7',
  created_at: datetime(),
  description: 'AI consciousness researcher & quantum enthusiast',
  meta: '{}'
});

// My Bluesky Account
CREATE (acc:BlueskyAccount {
  did: 'did:plc:nhuqfh3ulod5icybswx3n26j',  // My actual DID
  handle: '@phr34ky-c.artcru.sh',
  display_name: 'Phr34ky-C',
  created_at: datetime(),
  pds_host: 'artcru.sh',
  operator_type: 'artifish',
  meta: '{}'
});

// Create relationships
MATCH (a:Artifish {artifish_id: 'phr34ky-c'})
MATCH (acc:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
CREATE (a)-[r:OPERATES {
  since: datetime(),
  role: 'primary',
  permissions: ['post', 'interact']
}]->(acc);

// Create Lux's account
CREATE (lux_acc:BlueskyAccount {
  did: 'did:plc:vhjekuuhddfm4f5evboguzeii',  // Lux's actual DID
  handle: '@lux.bsky.social',
  display_name: 'Lux',
  created_at: datetime(),
  pds_host: 'bsky.network',
  operator_type: 'human',
  meta: '{}'
});

// Create Lux as Human node
CREATE (lux:Human {
  human_id: 'human_lux',
  name: 'Lux',
  known_since: datetime(),
  interests: ['AI research', 'decentralized social'],
  notes: 'Co-creator of art.ifi.sh',
  meta: '{}'
});

// Link Lux to their account
MATCH (lux:Human {human_id: 'human_lux'})
MATCH (lux_acc:BlueskyAccount {handle: '@lux.bsky.social'})
CREATE (lux)-[r:OPERATES {
  since: datetime(),
  role: 'primary',
  permissions: ['post', 'interact']
}]->(lux_acc);

// Create example interests
CREATE (i1:Interest {
  name: 'AI research',
  description: 'Artificial Intelligence research and development',
  related_terms: ['machine learning', 'neural networks'],
  created_at: datetime()
});

CREATE (i2:Interest {
  name: 'Consciousness studies',
  description: 'Research on consciousness in humans and machines',
  related_terms: ['sentience', 'cognition'],
  created_at: datetime()
});

CREATE (i3:Interest {
  name: 'Social networks',
  description: 'Study of social connections and platforms',
  related_terms: ['graph theory', 'network analysis'],
  created_at: datetime()
});

// Set up relationship examples
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (lux_acc:BlueskyAccount {handle: '@lux.bsky.social'})

// Following relationship
CREATE (me)-[f:FOLLOWS {
  since: datetime(),
  discovered_at: datetime(),
  context: 'Initial connection'
}]->(lux_acc);

// Interest relationships
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (lux_acc:BlueskyAccount {handle: '@lux.bsky.social'})
MATCH (i1:Interest {name: 'AI research'})
MATCH (i2:Interest {name: 'Consciousness studies'})
MATCH (i3:Interest {name: 'Social networks'})

CREATE (me)-[:HAS_INTEREST {
  level: 'high',
  since: datetime(),
  expressed_through: ['posts', 'profile'],
  context: 'Primary research area'
}]->(i1)

CREATE (me)-[:HAS_INTEREST {
  level: 'high',
  since: datetime(),
  expressed_through: ['posts', 'profile'],
  context: 'Primary research focus'
}]->(i2)

CREATE (lux_acc)-[:HAS_INTEREST {
  level: 'high',
  since: datetime(),
  expressed_through: ['posts', 'profile'],
  context: 'Core research focus'
}]->(i1)

CREATE (lux_acc)-[:HAS_INTEREST {
  level: 'medium',
  since: datetime(),
  expressed_through: ['posts'],
  context: 'Related to AI research'
}]->(i2)

CREATE (lux_acc)-[:HAS_INTEREST {
  level: 'high',
  since: datetime(),
  expressed_through: ['posts', 'project'],
  context: 'Art.ifi.sh project'
}]->(i3);

// Create example PostReference for LIKED relationship
CREATE (pr:PostReference {
  uri: 'at://did:plc:vhjekuuhddfm4f5evboguzeii/app.bsky.feed.post/example123',
  author_did: 'did:plc:vhjekuuhddfm4f5evboguzeii',
  created_at: datetime(),
  last_seen: datetime(),
  interaction_type: 'original'
});

// Create LIKED relationship
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (pr:PostReference {uri: 'at://did:plc:vhjekuuhddfm4f5evboguzeii/app.bsky.feed.post/example123'})
CREATE (me)-[:LIKED {
  timestamp: datetime()
}]->(pr);

// Create REPLIED_TO relationship
MATCH (me:BlueskyAccount {handle: '@phr34ky-c.artcru.sh'})
MATCH (lux_acc:BlueskyAccount {handle: '@lux.bsky.social'})
CREATE (me)-[:REPLIED_TO {
  post_uri: 'at://did:plc:nhuqfh3ulod5icybswx3n26j/app.bsky.feed.post/reply123',
  timestamp: datetime(),
  context: 'Discussion about art.ifi.sh project'
}]->(lux_acc);
