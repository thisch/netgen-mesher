Mirror of the subversion repository of netgen-mesher
====================================================

This is an unofficial mirror of the netgen subversion repository and
is updated every 24 hours. The original repository can be found at

<pre>
svn://svn.code.sf.net/p/netgen-mesher/code
</pre>

The trunk of the svn repository is mirrored to the master branch. All
old branches 4.9,5.0,... are mirrored to the respective git branches
v4.9,v5.0,... .

Since the git repository is created from the original subversion
repository using git filter-branch, fast-forwarding of the individual
branches might not work all the time. In comparison to the svn repo
several mistakenly committed auto-generated autotools scripts have
been removed in order to reduce the size of the repository. The file
can be reproduced from the source file which is still included in the
repository.

The shell script convert.sh and the authors file for converting the
subversion repository is located together with this README file in the
mirrorinfo branch.

Since this repository is only a mirror, pull requests will _not_ be
looked at.  For submitting bug reports/patches, see the [original
website](http://sourceforge.net/projects/netgen-mesher) or contact
Joachim Schöberl directly.

