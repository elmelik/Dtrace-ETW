#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright 2007 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#
# ident	"%Z%%M%	%I%	%E% SMI"

if [ $# != 1 ]; then
	echo expected one argument: '<'dtrace-path'>'
	exit 2
fi

dtrace=$1

# The output files assumes the timezone is US/Pacific
export TZ=America/Los_Angeles

(cat <<EOF
#pragma D option quiet
#pragma D option destructive

BEGIN
{
	@foo = min(1075064400 * (hrtime_t)1000000000);
	@bar = max(walltimestamp);
	printa("%@T\n", @foo);
	printa("%@Y\n", @foo);

	freopen("/dev/null");
	printa("%@T\n", @bar);
	printa("%@Y\n", @bar);

	exit(0);
}
EOF
) > /tmp/dtest.$$
$dtrace -s /tmp/dtest.$$

if [ $? -ne 0 ]; then
	print -u2 "dtrace failed"
	exit 1
fi

exit 0
