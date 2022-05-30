#!/bin/bash
##
# Bump package.json version string for github actions release process.
#
# Inputs:
#  - EXTENDED_TAG: An optional env variable containing a string indicating the
#    build type.
#
# Outputs:
# - package.json: A package.json file with the new version number, but ONLY if
#   the version conforms to the semver specification.

EXTENDED_TAG=${INPUT_EXTENDEDTAG}
INCLUDE_SHA=${INPUT_APPENDSHA}

# echo "Hello from github action: ${METADATA_STRING}"
WORKDIR=`pwd`

# cat $WORKDIR/.npmrc

# Get the current version, discarding any quotes and any additional tags
CURRENT_VERSION=$(cat package.json | grep "\"version\"" | tr -cd "[[:digit:].]")

VERSION_ITERATOR=$([[ ${GITHUB_RUN_ATTEMPT} -gt ${GITHUB_RUN_NUMBER} ]] && echo ${GITHUB_RUN_ATTEMPT} || echo ${GITHUB_RUN_NUMBER})
NEW_VERSION="${CURRENT_VERSION}-${EXTENDED_TAG}${VERSION_ITERATOR}"

if [ ${INPUT_APPENDSHA} ]
then
  FILTERED_SHA=$(echo ${GITHUB_SHA} | sed 's,.*\(.\{7\}\)$,\1,')
  NEW_VERSION=${NEW_VERSION}.${FILTERED_SHA}
fi

# Verify that it's semver-certified
VALID_VERSION=`npx semver $NEW_VERSION`

if [ -z $VALID_VERSION ]
then
  echo "Version not valid"
  exit 1
fi

# Replace the old version with the new version in package.json
sed -i -e 's/'"${CURRENT_VERSION}"'/'"${NEW_VERSION}"'/' package.json
cat package.json

# IN_ARRAY=1
# VERSIONS=`npm --registry=https://npm.pkg.github.com/ view @foamfactory/aegir versions --json`

# while [ $IN_ARRAY -eq 1 ]
# do
#   NEW_VERSION="$CURRENT_VERSION-$EXTENDED_TAG$VERSION_ITERATOR"
#
#   # Verify that it's semver-certified
#   VALID_VERSION=`npx semver $NEW_VERSION`
#
#   if [ -z $VALID_VERSION ]
#   then
#     echo "Version not valid"
#     exit 1
#   fi
#
#   # Verify that there isn't already a release with this name
#   IN_ARRAY=`node contrib/check-in-array.js "{\"versions\":$VERSIONS}" $NEW_VERSION`
#   VERSION_ITERATOR=$((VERSION_ITERATOR+1))
# done
#
# if [ $IN_ARRAY -eq 2 ]
# then
#   echo "There were no versions in the version array"
#   exit 1
# fi
#
# cp $WORKDIR/package.json $WORKDIR/package.json.old
# jq --arg v "$NEW_VERSION" '.version=$v' $WORKDIR/package.json > $WORKDIR/package.json.new
# rm $WORKDIR/package.json
# mv $WORKDIR/package.json.new $WORKDIR/package.json
# cat $WORKDIR/package.json
