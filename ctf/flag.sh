#!/bin/sh
# >>> isoloom-1.0 secret-from-file shim (auto-added by convert-lab.py) >>>
# Inputs now arrive as files (isoloom.yml `files:`), not environment variables.
# Read each into its old variable when unset, keeping the dev/CI fallback working.
for __p in CTF_FLAG_MAIN:/run/lab/ctf_flag_main; do
  __n=${__p%%:*}; __f=${__p#*:}
  eval "__v=\${$__n:-}"
  if [ -z "$__v" ] && [ -s "$__f" ]; then
    __v=$(tr -d '\r\n' < "$__f"); eval "export $__n=\"\$__v\""
  fi
done
unset __p __n __f __v 2>/dev/null || true
# <<< isoloom-1.0 secret-from-file shim <<<
# Places the player's flag (CTF_FLAG_MAIN, given by the launcher) as the game of one more valid
# coupon, shown when that coupon is redeemed; without one (CI, a run by hand) the development
# flag. Uses the app's own MySQLdb and its baked-in database settings.
dev='FLAG{dev-secdevlabs-games-irados}'
FLAG="${CTF_FLAG_MAIN:-$dev}" python - <<'PY'
import os, time, MySQLdb
for _ in range(90):
    try:
        db = MySQLdb.connect(host=os.environ['MYSQL_ENDPOINT'], user=os.environ['MYSQL_USER'],
                             passwd=os.environ['MYSQL_PASSWORD'], db=os.environ['MYSQL_DB'])
        c = db.cursor(); c.execute('SELECT 1 FROM coupons LIMIT 1'); break
    except Exception:
        time.sleep(2)
c.execute('INSERT INTO coupons (coupon, game, valid) VALUES (%s, %s, 1) '
          'ON DUPLICATE KEY UPDATE game = VALUES(game), user = NULL, valid = 1', ('k3x9q', os.environ['FLAG']))
db.commit()
PY
