# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name cargo
# @brief Simple environment setup for using `cargo` as a package manager.
# @repository https://github.com/johnstonskj/zsh-cargo-plugin
#

############################################################################
# @section Public
# @description Useful Cargo functions.
#

function cargo_all_installed {
    builtin emulate -L zsh

    local list=$(cargo install --list |grep -E "^[^ ]" | cut -d ' ' -f 1 | tr '\n' ':')
    printf '%s' ":${list}:"
}
@zplugins_remember_fn cargo cargo_all_installed

function cargo_crate_exists {
    builtin emulate -L zsh

    [[ ":$(cargo_all_installed):" == *":${1}:"* ]]
}
@zplugins_remember_fn cargo cargo_crate_exists

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

cargo_plugin_init() {
    builtin emulate -L zsh

    @zplugins_envvar_save cargo CARGO_HOME

    export CARGO_HOME="${CARGO_HOME:-${HOME}/.cargo}"

    @zplugins_add_to_path cargo "${CARGO_HOME}/bin"
}

# @internal
cargo_plugin_unload() {
    emulate -L zsh

    @zplugins_envvar_restore cargo CARGO_HOME
}
