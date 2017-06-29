# -*- shell-script -*-
# bash completion script for MINCS

# Check whether @arg is already used
__arg_used() { # arg
  local i=0
  while [ $i -lt $COMP_CWORD ]; do
    test x"${COMP_WORDS[i]}" = x"$1" && return 0
    i=$((i+1))
  done
  return 1
}

# Check whether @args *are* already used
_arg_used() { # args
  while [ "$#" -ne 0 ]; do
    __arg_used $1 && return 0
    shift 1
  done
  return 1
}

# Check the @arg is included in @arg_list
_arg_included() { # arg arg_list
  local cur=$1
  shift 1
  while [ "$#" -ne 0 ]; do
    test x"$cur" = x"$1" && return 0
    shift 1
  done
  return 1
}

# Completion function
_minc() { # command current prev
  local help_flags="-h --help"
  local noarg_flags="-k --keep -D --direct -X --X11 --net -B --background --usedev --pivot --debug"
  local dir_flags="-t --tempdir -r --rootdir --nopriv"
  local file_flags="--ftrace"
  local arch_flags="--cross --arch"
  local arg_flags="-c --cpu -b --bind -p --port --name --user --nocaps --mem-limit --mem-swap --cpu-shares --cpu-quota --pid-max"
  local virt_flags="--um --qemu"

  local prev=$3
  local cur=$2

  # If there is --help option, no more options available.
  if _arg_used $help_flags ; then
    return 0
  elif [ $COMP_CWORD -ne 0 ]; then
    # If there are other options, we don't need help anymore.
    help_flags=
  fi

  # If there is virt options are selected, no need to use it.
  if _arg_used $virt_flags ; then
    virt_flags=
  fi

  if _arg_included $prev $dir_flags ; then
    COMPREPLY=($(compgen -d $cur))
  elif _arg_included $prev $file_flags ; then
    COMPREPLY=($(compgen -f $cur))
  elif _arg_included $prev $arch_flags ; then
    COMPREPLY=($(compgen -W "x86_64 amd64 i386 arm arm64 aarch64" -- $cur))
  elif _arg_included $prev $arg_flags ; then
    local ifs=$IFS
    IFS=$'\n'
    COMPREPLY=(`$1 -h | grep -e "[[:space:]]$3[[:space:]]" | cut -f1` ".")
    IFS=$ifs
  else
    if _arg_used $arch_flags ; then
      arch_flags=
    fi
    local flags="$help_flags $noarg_flags $dir_flags $file_flags $arch_flags $arg_flags $virt_flags"
    COMPREPLY=($(compgen -W "$flags" -- $cur))
  fi
}

complete -F _minc minc
