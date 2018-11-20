source $utils

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

function apply_depinfo {
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
                RUSTFLAGS+=" -L$val"
            ;;
            *)
                export DEP
                printf \
                    -v$out_deps \
                    '%s DEP_%s_%s="%q"' \
                    "${!out_deps}" \
                    "$(upper $links)" \
                    "$(upper $key)" \
                    "$val"
        esac
    done
}
