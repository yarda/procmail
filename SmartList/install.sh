#! /bin/sh
: &&O='cd .' || exec /bin/sh "$0" $argv:q # we're in a csh, feed myself to sh
$O || exec /bin/sh "$0" "$@"		  # we're in a buggy zsh
#$Id: install.sh,v 1.39 1994/02/08 16:13:38 berg Exp $

SHELL=/bin/sh
export SHELL
umask 022				# making sure that umask has sane value

test $# != 1 -a $# != 2 && echo "Usage: install.sh target-directory [.bin]" &&
 exit 64

target="$1"
bindir="$2"

test -z "$bindir" && bindir=.bin

test ! -d "$target" && echo "Please create the target directory first" &&
 echo "Make sure it has the right owner" && exit 2

if test ! -f ../config.h
then
  echo "You must merge the source trees of procmail and SmartList"
  echo "together.  Simply unpack them on top of each other."
  exit 2
fi

if binmail=`procmail /dev/null DEFAULT=/dev/null 'LOG=$SENDMAIL' \
  </dev/null 2>&1`
then
  case "$binmail" in
     ""|*procmail:*)
	 echo "Failed in extracting the value of SENDMAIL from procmail"
	 echo \
	"Please make sure that the new version of procmail has been installed"
	 echo \
       'If you already have, make sure that "console" is undefined in config.h'
	 exit 64 ;;
  esac
else
  echo "Please make sure that procmail is on our PATH"
  exit 64
fi

if expr "X$bindir" : X.bin >/dev/null
then
:
else
  echo "I prefer a bin directory that starts with .bin"
  echo "If you want to enforce a different name, patch install.sh first :-)."
  exit 64
fi

cd "`dirname $0`"
PATH=.:$PATH

export target bindir binmail PATH

TMPF=/tmp/list.id.$$

trap "/bin/rm -f $TMPF; exit 1" 1 2 3 15

/bin/rm -f $TMPF

echo Id test >$TMPF

AM_ROOT=no

if ls -l $TMPF | grep '^[^ ]*  *[0-9][0-9]*  *root ' >/dev/null
then
  /bin/rm -f $TMPF
  AM_ROOT=yes
  installerid=`ls -l ../Makefile |
   sed -e 's/^[^ ]* *[0-9][0-9]*[^0-9] *\([^ ]*\) .*$/\1/'`
  listid=`ls -ld $target/. |
   sed -e 's/^[^ ]* *[0-9][0-9]*[^0-9] *\([^ ]*\) .*$/\1/'`
  if test root = $listid
  then
     echo "Please give $target the right owner & group first"
     exit 2
  fi
else
  /bin/rm -f $TMPF
  if ( echo Id test >id.test ) 2>/dev/null
  then
  :
  else	# You can run install.sh WITHOUT root permissions as well!
     echo "Please run install.sh with root permissions instead"
     exit 77
  fi
  /bin/rm -f id.test
  listid=`ls -l install.sh |
   sed -e 's/^[^ ]* *[0-9][0-9]*[^0-9] *\([^ ]*\) .*$/\1/'`
fi

trap "" 1 2 3 15

export listid

if test $AM_ROOT = yes
then
  case $installerid in
     [0-9]*) exec 4>&0
	 . ./install.sh2
	 exec 4>&- ;;
     *) su $installerid 4>&0 <install.sh2 || exit 1;;
  esac
  if echo ls | su $listid 2>&1 | fgrep install.sh2 >/dev/null
  then
  :
  else
     echo "It seems that the user \"$listid\" is not able to access"
     echo "files in the current directory (procmail/mailinglist/.)."
     echo "You have to make sure that at least while the install.sh"
     echo "scripts are running, the procmail source tree is accessible"
     echo "AND readable for that user."
     exit 64
  fi
  su $listid <install.sh3
  echo "Making $target/$bindir/flist suid root..."
  if chown root "$target/$bindir/flist" && chmod 04755 "$target/$bindir/flist"
  then
  :
  else
     echo "You either have to symlink the $target/$bindir"
     echo "directory to a partition where root has root permissions;"
     echo "or make sure that root can use its rights on the existing"
     echo "partition (that contains $target/$bindir)."
     echo "Then run this script again."
     exit 64
  fi
else
  exec 4>&0
  . ./install.sh2
  exec 4>&-
  . ./install.sh3
fi

echo '**********************************************************************'
echo "Finished installing, now you should"
if test -f $target/.etc/rc.init.new
then
  echo "edit $target/.etc/rc.init.new,"
  echo "AND *cat* (preserving hardlinks!) it into the"
  echo "old $target/.etc/rc.init to make sure"
else
  echo "edit $target/.etc/rc.init to make sure"
fi
echo "that \`PATH', \`domain' and \`listmaster' reflect your installation."
if test -f $target/.etc/rc.init.new
then
  echo "Finally, to reenable the lists execute:"
  echo "		/bin/rm -f $target/.etc/rc.lock"
  touch "$target/.etc/rc.lock"
fi
echo '**********************************************************************'
