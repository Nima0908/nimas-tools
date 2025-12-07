#!/bin/bash
# Bash completion for genup

_genup()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    opts="-a --ask -A --alert -b --buildkernel-args -c --dispatch-conf -C --no-custom-updaters \
          -d --deploy-from-staging -e --emerge-args -E --no-emtee -g --pgmerge \
          -F --no-fixups -h --help -i --ignore-required-changes -k --keep-old-distfiles \
          -m --no-eix-metadata-update -M --no-module-rebuild -n --no-kernel-upgrade \
          -N --no-nocache -p --no-perl-cleaner -r --adjustment -S --no-eix-sync \
          -v --verbose -V --version -x --eix-sync-args"
    
    if [[ ${cur} == -* ]]; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
    
    case "${prev}" in
        -b|--buildkernel-args|-e|--emerge-args|-r|--adjustment|-x|--eix-sync-args)
            COMPREPLY=( $(compgen -A file -- ${cur}) )
            return 0
            ;;
    esac
    
    return 0
}

complete -F _genup genup
