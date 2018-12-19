def all_dependencies:
  .["dependencies", "dev-dependencies", "build-dependencies"];

def optional_dependencies:
  [ all_dependencies | select(.) ]
  | add // {}
  | map_values(select(type == "object" and .optional));

def augment_features:
  .features = (.features + optional_dependencies);

def remove_dependencies:
  del(all_dependencies)
  | .target |= ((.//{}) | map_values(del(all_dependencies)));

def remove_feature_dependencies:
  .features |= map_values([]);

augment_features
  | remove_feature_dependencies
  | remove_dependencies
