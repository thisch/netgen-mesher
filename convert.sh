#!/bin/sh

action=$1

set -e
set -u

# Several branches
# Branch upstream: complete svn repo, including branch directory
# Branch master: upstream without branch information and svn-id's in commits
# Branch v4.9, v5.0,...: Branches from upstream

NGDIR=netgen-mirror

if [ "${action}" = "init" ]; then
    git svn clone -A ngs_authors.txt -T ./ --ignore-paths '^(branches/netgen-4.9-del|netgen-4.9)' svn://svn.code.sf.net/p/netgen-mesher/code ${NGDIR}
    git remote add github github_mirror:mliertzer/netgen-mesher.git
    cd ${NGDIR}
    git checkout -b upstream
    git branch -d master
    git checkout --orphan mirrorinfo
    git checkout upstream
    cd ..
fi

cd ${NGDIR}
git checkout upstream
git svn rebase

branchversions=$(ls -d branches/netgen-* | sed -e 's#branches/netgen-##')

for i in $(git branch --list master v* | cut -c3-); do  
    git branch -D $i;
done

git gc

git branch master upstream
git filter-branch --index-filter \
     'git ls-files -s | sed "/\tbranches/d" | GIT_INDEX_FILE=$GIT_INDEX_FILE.new git update-index --index-info &&
      mv "$GIT_INDEX_FILE.new" "$GIT_INDEX_FILE"' --msg-filter 'sed -e "/^git-svn-id:/d"' --prune-empty -f master

for bv in ${branchversions}; do
    bn=v${bv}
    git branch ${bn} upstream
    git filter-branch --index-filter\
    "set -e
     set -u
     TMPFILE=\$(mktemp)
     git ls-files -s > \${TMPFILE};
     if grep -q '	branches/netgen-${bv}/' \${TMPFILE}; then
          sed '/\tnetgen\//d
s#\tbranches/netgen-${bv}/#\tnetgen/#
/\tbranches/d' \${TMPFILE} | sort -k 3 > \${TMPFILE}.bak
     else
          sed '/\tbranches/d' \${TMPFILE} > \${TMPFILE}.bak
     fi
     mv \${TMPFILE}.bak \${TMPFILE}
     GIT_INDEX_FILE=\"\${GIT_INDEX_FILE}.new\" git update-index --index-info < \${TMPFILE} &&
     mv \"\${GIT_INDEX_FILE}.new\" \"\${GIT_INDEX_FILE}\"
     rm \${TMPFILE}" --msg-filter 'sed -e "/^git-svn-id:/d"' --prune-empty -f ${bn}
done

git push github +master:master
for bv in ${branchversions}; do
    bn=v${bv}
    git push github +${bn}:${bn}
done

if ! git checkout mirrorinfo; then
    git checkout --orphan mirrorinfo
    git reset --hard
fi
cp ../${0} convert.sh
cp ../ngs_authors.txt .
cat > README.md << EOF
Mirror of the subversion repository of netgen-mesher
====================================================

This is an unofficial mirror of the netgen subversion repository and
is updated every 24 hours. The original repository can be found at

<pre>
svn://svn.code.sf.net/p/netgen-mesher/code
</pre>

The trunk of the repository can be found in the master branch. All old
branches 4.9,5.0,... are in respective git branches v4.9,v5.0,... .

Since the git repository is created from the original subversion
repository using git filter-branch, fast-forwarding of the individual
branches might not work all the time.

The shell script convert.sh and the authors file for converting the
subversion repository is located together with this README file in the
mirrorinfo branch.

Since this repository is only a mirror, pull requests will _not_ be
accepted/looked at.  For submitting bug reports/patches, see the 
[original website](http://sourceforge.net/projects/netgen-mesher)
or contact Joachim Schöberl directly.

EOF

git add convert.sh ngs_authors.txt README.md
git commit -m "Update mirror info"
git push github mirrorinfo:mirrorinfo

git checkout upstream
cd ..
