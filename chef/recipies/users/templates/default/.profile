# ~/.profile: handy thing to stop me going nuts.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

mesg n