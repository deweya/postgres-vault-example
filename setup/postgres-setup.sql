CREATE TABLE customer (
  id BIGINT PRIMARY KEY NOT NULL,
  first_name VARCHAR(255),
  last_name VARCHAR(255)
);
CREATE SEQUENCE hibernate_sequence START 1 INCREMENT 1;

CREATE ROLE widget NOLOGIN INHERIT;
GRANT ALL privileges ON customer TO widget;
GRANT usage, SELECT ON SEQUENCE hibernate_sequence TO widget;

CREATE ROLE widget_blue LOGIN PASSWORD 'widget_blue_pass' IN ROLE widget;