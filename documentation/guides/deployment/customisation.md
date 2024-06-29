# Customisation
Angen is setup to be as game-agnostic as possible and ready out-of-the-box as possible. Unfortunately there are always some things we can't make work everywhere all the time. This guide goes through each of the items you will want to tweak.

## Favicon
`scp -i ~/.ssh/id_rsa favicon.ico deploy@yourdomain.com:/var/www/`

## Fontawesome
The site makes liberal use of [FontAwesome](https://fontawesome.com/) so you will want to grab a copy yourself.
```bash
fontawesome/css/all.css -> priv/static/css/fontawesome.css
fontawesome/webfonts -> priv/static/webfonts
```

You can configure free vs pro mode using [configs](config.md#fontawesome_free_only)
