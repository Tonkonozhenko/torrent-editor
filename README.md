Torrent editor
===

Start
---
`vagrant up`

Manual start
---

It can be launched only from `Ubuntu` with `Ruby >= 2.0`

```
bundle install
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rackup -p 3000 -o 0.0.0.0 -P ./tmp/server.pid -D  
```