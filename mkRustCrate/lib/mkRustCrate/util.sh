function upper {
    local x="${1//-/_}"
    echo "${x^^}"
}

function lower {
    local x="${1//_/-}"
    echo "${x,,}"
}

function crate_hash {
    local x=$(basename "$1")
    echo "${x%%-*}"
}

function crate_name {
    local name=$(basename "${1#*-}")
    echo "${name//-/_}"
}

function flags {
    for dep in ${!1}
    do
        local name=$(crate_name $dep)
        local hash=$(crate_hash $dep)
        echo "-L $dep/lib"
        echo "--extern $name=$dep/lib/lib$name-$hash.rlib"
    done
}

function filext {
    local ext="$(basename $1)"
    echo ${ext#*.}
}

function copy_or_link {
    local src="$1"; shift
    local dest="$1"; shift
    [ -L "$src" ] \
        && cp -dn "$src" "$dest" \
        || ln -s "$src" "$dest" &> /dev/null || true
}

function parse_depinfo {
    echo NIX_RUST_LINK_FLAGS=\"\${NIX_RUST_LINK_FLAGS-}\"
    cat "$@" | while read line
    do
        [[ "x$line" =~ xcargo:([^=]+)=(.*) ]] || continue
        local key="${BASH_REMATCH[1]}"
        local val="${BASH_REMATCH[2]}"

        case $key in
            rustc-link-lib) ;&
            rustc-flags) ;&
            rustc-cfg) ;&
            rustc-env) ;&
            rerun-if-changed) ;&
            rerun-if-env-changed) ;&
            warning)
            ;;
            rustc-link-search)
                printf 'NIX_RUST_LINK_FLAGS+=" "-L%q\n' "$val"
                ;;
            *)
                printf 'export DEP_%s_%s=%q\n' \
                       "$(upper $CARGO_LINKS)" \
                       "$(upper $key)" \
                       "$val"
        esac
    done
}
