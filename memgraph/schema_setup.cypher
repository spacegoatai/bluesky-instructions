// Artifish Memgraph Schema v2.0 - Setup Script

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
  did: 'did:plc:vhjekuuhddfm4f5evboguzei',  // Lux's actual DID
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

// We'll add more nodes and relationships as we interact with Bluesky!