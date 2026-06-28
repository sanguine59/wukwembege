CREATE DATABASE IF NOT EXISTS wukwembege;
USE wukwembege;

DROP TABLE IF EXISTS notifs;
DROP TABLE IF EXISTS participation;
DROP TABLE IF EXISTS stalls;
DROP TABLE IF EXISTS event_tags;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS settings;
DROP TABLE IF EXISTS profiles;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id            VARCHAR(64)  NOT NULL,
  email         VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email)
);

CREATE TABLE profiles (
  user_id    VARCHAR(64)  NOT NULL,
  name       VARCHAR(255) NOT NULL DEFAULT '',
  owner      VARCHAR(255) NOT NULL DEFAULT '',
  role       ENUM('organizer','vendor') NOT NULL DEFAULT 'organizer',
  role_label VARCHAR(255) NULL,
  events     INT          NULL,
  vendors    INT          NULL,
  cuisine    VARCHAR(255) NULL,
  rating     DECIMAL(3,2) NULL,
  reviews    INT          NULL,
  bio        TEXT         NULL,
  color      VARCHAR(32)  NOT NULL DEFAULT 'blue',
  glyph      VARCHAR(32)  NOT NULL DEFAULT 'store',
  email      VARCHAR(255) NOT NULL DEFAULT '',
  phone      VARCHAR(64)  NOT NULL DEFAULT '',
  PRIMARY KEY (user_id),
  CONSTRAINT fk_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE settings (
  user_id      VARCHAR(64) NOT NULL,
  push_apps    TINYINT(1)  NOT NULL DEFAULT 1,
  push_updates TINYINT(1)  NOT NULL DEFAULT 1,
  email        TINYINT(1)  NOT NULL DEFAULT 0,
  visible      TINYINT(1)  NOT NULL DEFAULT 1,
  location     TINYINT(1)  NOT NULL DEFAULT 1,
  PRIMARY KEY (user_id),
  CONSTRAINT fk_settings_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE events (
  id          VARCHAR(64)  NOT NULL,
  collection  ENUM('events','browse') NOT NULL DEFAULT 'events',
  name        VARCHAR(255) NOT NULL DEFAULT '',
  type        VARCHAR(64)  NOT NULL DEFAULT '',
  status      ENUM('live','upcoming','past') NOT NULL DEFAULT 'upcoming',
  color       VARCHAR(32)  NOT NULL DEFAULT 'blue',
  glyph       VARCHAR(32)  NOT NULL DEFAULT 'store',
  date_label  VARCHAR(128) NOT NULL DEFAULT '',
  time        VARCHAR(128) NOT NULL DEFAULT '',
  location    VARCHAR(255) NOT NULL DEFAULT '',
  city        VARCHAR(128) NOT NULL DEFAULT '',
  capacity    INT          NOT NULL DEFAULT 0,
  fee         INT          NOT NULL DEFAULT 0,
  attendees   VARCHAR(64)  NOT NULL DEFAULT '',
  descr       TEXT         NULL,
  organizer   VARCHAR(255) NULL,
  taken       INT          NULL,
  join_state  VARCHAR(64)  NULL,
  PRIMARY KEY (id),
  KEY idx_events_collection (collection)
);

CREATE TABLE event_tags (
  event_id VARCHAR(64)  NOT NULL,
  tag      VARCHAR(128) NOT NULL,
  PRIMARY KEY (event_id, tag),
  CONSTRAINT fk_tags_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
);

CREATE TABLE stalls (
  id       VARCHAR(64)  NOT NULL,
  event_id VARCHAR(64)  NOT NULL,
  position INT          NOT NULL DEFAULT 0,
  name     VARCHAR(255) NOT NULL DEFAULT '',
  cuisine  VARCHAR(255) NOT NULL DEFAULT '',
  owner    VARCHAR(255) NOT NULL DEFAULT '',
  status   ENUM('confirmed','pending','declined') NOT NULL DEFAULT 'pending',
  spot     VARCHAR(32)  NOT NULL DEFAULT '-',
  fee      INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_stalls_event (event_id),
  CONSTRAINT fk_stalls_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
);

CREATE TABLE participation (
  user_id  VARCHAR(64) NOT NULL,
  event_id VARCHAR(64) NOT NULL,
  status   VARCHAR(64) NOT NULL DEFAULT 'pending',
  spot     VARCHAR(32) NULL,
  PRIMARY KEY (user_id, event_id),
  CONSTRAINT fk_part_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE notifs (
  id         VARCHAR(64)  NOT NULL,
  user_id    VARCHAR(64)  NOT NULL,
  kind       VARCHAR(32)  NOT NULL DEFAULT 'system',
  is_read    TINYINT(1)   NOT NULL DEFAULT 0,
  time       VARCHAR(64)  NOT NULL DEFAULT '',
  actor      VARCHAR(255) NOT NULL DEFAULT '',
  cuisine    VARCHAR(255) NULL,
  event_id   VARCHAR(64)  NULL,
  event_name VARCHAR(255) NOT NULL DEFAULT '',
  text       TEXT         NOT NULL,
  actionable TINYINT(1)   NOT NULL DEFAULT 0,
  stall_id   VARCHAR(64)  NULL,
  resolved   VARCHAR(64)  NULL,
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_notifs_user (user_id),
  CONSTRAINT fk_notifs_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
