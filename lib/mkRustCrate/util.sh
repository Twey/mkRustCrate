function upper {
    x=${1//-/_}
    echo ${x^^}
}

function lower {
    x=${1//_/-}
    echo ${x,,}
}
