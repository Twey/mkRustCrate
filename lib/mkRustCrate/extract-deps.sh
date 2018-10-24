[ $# -eq 0 ] && exit 0

source $utils

cat "$@" | while read line
do
    [ "xcargo:" = "x${line::6}" ] && line=${line:6} || continue
    echo "x$line" | grep = &>/dev/null || continue
    
    key=${line%%=*}

    case $key in
        rustc-link-lib) ;&
        rustc-link-search) ;&
        rustc-flags) ;&
        rustc-cfg) ;&
        rustc-env) ;&
        rerun-if-changed) ;&
        rerun-if-env-changed) ;&
        warning)
            continue
            ;;
    esac

    val=${line#*=}
    key=$(upper "$key")
    echo "export DEP_@links@_$key=\"$val\""
done
