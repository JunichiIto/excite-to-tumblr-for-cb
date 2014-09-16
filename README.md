Excite To Tumblr For Cb
================

Personal utility tool for migration from Excite blog to Tumblr.

How to use
-----------

NOTE: IF YOU USE THIS UTILITY, DO IT AT YOUR OWN RISK.

1. Create `config/database.yml` and `rake db:create`. PostgreSQL is recommended.
1. [Register your Tumblr application.](https://www.tumblr.com/oauth/apps)
1. [Get your access token and secret.](https://api.tumblr.com/console/calls/user/info)
1. Edit `config/settings.yml` or create `config/settings.local.yml` for credentials.
1. Execute `BlogPost.import_all_posts`.
1. Execute `BlogImage.create_blog_images`.
1. Execute `BlogImage.link_all_posts_and_images`.
1. Execute `BlogImage.post_all_images_to_tumblr` (NOTE: Max 150 images per day).
1. Install Firefox to your machine.
1. Execute `BlogPost.post_all_posts_to_tumblr` (NOTE: Max 250 posts per day).
