create table customer (
  id bigint primary key not null,
  first_name varchar(255),
  last_name varchar(255)
);
create sequence hibernate_sequence start 1 increment 1;

create role widget nologin inherit;
grant all privileges on customer to widget;
grant usage, select on sequence hibernate_sequence to widget;

create role widget_blue login password 'password' in role widget;

create role widget_green nologin password 'password' in role widget;

-- Run these to switch to the "green" role
alter role widget_green login;
alter role widget_blue nologin; 