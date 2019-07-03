#! /usr/bin/ksh
#
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#

#
# Copyright (c) 2013 Joyent, Inc. All rights reserved.
#

#
# This test is checking that we can read members and that pointers inside
# members point to valid data that is intelligible, eg. strings.
#

if [ $# != 1 ]; then
        echo expected one argument: '<'dtrace-path'>'
        exit 2
fi

dtrace=$1
t="zelda_info_t"
exe="tst.chasestrings.exe"

# elfdump "./$exe" | grep -q '.SUNW_ctf' 
# if [[ $? -ne 0 ]]; then
# 	echo "CTF does not exist in $exe, that's a bug" >&2
# 	exit 1
# fi


(cat <<EOF
pid\$target::has_princess:entry
/next == 0/
{
	this->t = (pid\`$t *)(copyin(arg0, sizeof (pid\`$t)));
	printf("game: %s, dungeon: %d, villain: %s, zelda: %d\n",
	    copyinstr((uintptr_t)this->t->zi_gamename), this->t->zi_ndungeons,
	    copyinstr((uintptr_t)this->t->zi_villain), this->t->zi_haszelda);
	next = 1;
}

pid\$target::has_dungeons:entry
/next == 1/
{
	this->t = (pid\`$t *)(copyin(arg0, sizeof (pid\`$t)));
	printf("game: %s, dungeon: %d, villain: %s, zelda: %d\n",
	    copyinstr((uintptr_t)this->t->zi_gamename), this->t->zi_ndungeons,
	    copyinstr((uintptr_t)this->t->zi_villain), this->t->zi_haszelda);
	next = 2;
}

pid\$target::has_villain:entry
/next == 2/
{
	this->t = (pid\`$t *)(copyin(arg0, sizeof (pid\`$t)));
	printf("game: %s, dungeon: %d, villain: %s, zelda: %d\n",
	    copyinstr((uintptr_t)this->t->zi_gamename), this->t->zi_ndungeons,
	    copyinstr((uintptr_t)this->t->zi_villain), this->t->zi_haszelda);
	exit(0);
}
EOF
)  > /tmp/dtest.$$

$dtrace -qs /tmp/dtest.$$ -c $exe
rc=$?


exit $rc
