def walk(f):
  . as $in
  | if type == "object" then
      reduce keys[] as $key
        ( {}; . + { ($key):  ($in[$key] | walk(f)) } ) | f
  elif type == "array" then map( walk(f) ) | f
  else f
  end;

def remove_forbidden_keys:
  del(.[
    "dependencies",
    "dev-dependencies",
    "build-dependencies",
    "features"
  ]);

remove_forbidden_keys
  | .target |= ((.//{}) | map_values(remove_forbidden_keys))
