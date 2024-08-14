#!/bin/bash

redis-server --daemonize yes

bundle exec ruby app.rb
