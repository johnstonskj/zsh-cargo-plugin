# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA CARGO
CARGO[_PLUGIN_DIR]="${0:h}"
CARGO[_FUNCTIONS]=""

############################################################################
# Internal Support Functions
############################################################################

#
# This function will add to the `CARGO[_FUNCTIONS]` list which is
# used at unload time to `unfunction` plugin-defined functions.
#
_cargo_remember_fn() {
    emulate -L zsh

    local fn_name="${1}"
    if [[ -z "${CARGO[_FUNCTIONS]}" ]]; then
        CARGO[_FUNCTIONS]="${fn_name}"
    elif [[ ",${CARGO[_FUNCTIONS]}," != *",${fn_name},"* ]]; then
        CARGO[_FUNCTIONS]="${CARGO[_FUNCTIONS]},${fn_name}"
    fi
}
_cargo_remember_fn _cargo_remember_fn

############################################################################
# Public Functions
############################################################################

export CARGO_HOME="${CARGO_HOME:-${HOME}/.cargo}"
path_append "${CARGO_HOME}/bin"

function cargo_all_installed {
    local list=$(cargo install --list |grep -E "^[^ ]" | cut -d ' ' -f 1 | tr '\n' ':')
    echo ":${list}:"
}
_cargo_remember_fn cargo_all_installed

function cargo_crate_exists {
    [[ ":$(cargo_all_installed):" == *":${1}:"* ]]
}
_cargo_remember_fn cargo_crate_exists

############################################################################
# Plugin Unload Function
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
cargo_plugin_unload() {
    emulate -L zsh

    # Remove all remembered functions.
    local plugin_fns
    IFS=',' read -r -A plugin_fns <<< "${CARGO[_FUNCTIONS]}"
    local fn
    for fn in ${plugin_fns[@]}; do
        whence -w "${fn}" &> /dev/null && unfunction "${fn}"
    done

    # Remove the global data variable.
    unset CARGO

    # Remove self from fpath.
    # shellcheck disable=SC2296
    fpath=("${(@)fpath:#${0:A:h}}")

    # Remove this function.
    unfunction "cargo_plugin_unload"
}

true
