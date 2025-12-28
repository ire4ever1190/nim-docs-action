#!/bin/bash
#
# This script checks out a version and builds all the documentation for it
# Args:
#  - $1: Version that corresponds to a git reference that should be built
#  - $2: Folder containing the .nimble file
#  - $3: Main .nim file to use as entrypoint for documentation
#  - $4: Which branch to link users too if they want to edit something
#  - $5: Whether to build an indexs first (needed for importdoc)
#  - $6: Space separated list of extra files to generate docs for
#  - $7: Base folder to output to

# Until we need to do all the versions, we can safely source here
cd $2
source nimbleVar.sh

case "$1" in
  stable)
    # Find a tag that matches the version specified in the nimble file
    git fetch --tags
    # We need to hide grep errors when it doesn't match
    # https://stackoverflow.com/a/49627999/21247938
    found_ver=$(git tag -l | { grep -E -m 1 "v?$nimble_version" || test $? = 1; })
    if [ ! -z "$found_ver" ]
    then
        git checkout "$found_ver"
    fi
    echo "Generating for $found_ver" ;;
  HEAD)
    newFile=${file/%nim/html}
    found_ver="develop"
    echo "Generating for latest commit" ;;
  *)
    echo "Unknown version: $1"
    exit 1;;
esac

output_dir="$7/${found_ver}"

git checkout $1

# To remove the src/ prefix in the pages we add a dummy
# .nimble file so that Nim thinks the files are root level
touch "$nimble_srcDir/dummy.nimble"

# To support `importdoc` we need to first build the
# indexes
if [[ $5 == "true" ]]; then
    nimble -y doc \
        --project \
        --outdir=${output_dir} \
        --docCmd:skip \
        --index:only \
        --warningAsError:BrokenLink:on \
        --warningAsError:AmbiguousLink:on \
        -d:docgen \
        $3
fi

# Go through each file and generate it
for file in $(ls ${{ inputs. extra-files }});
do
  # Change command depending on what the file is
  # TODO: Support RST
  case "$file" in
    *.md)
      newFile=${file/%md/html}
      cmd="nim md2html" ;;
    *.nim)
      newFile=${file/%nim/html}
      cmd="nimble -y doc" ;;
    *)
      echo "Whats ${file}?"
      echo "I don't know how to render this file..."
      exit 1;;
  esac
  indexFile="${output_dir}/${newFile/%html/idx}"
  # Build the file
  echo "Documenting ${file}..."
  $cmd --docroot:"$(pwd)" --outdir="${output_dir}" --index:on -d:docgen $file

  # Make the title be markupTitle so it gets rendered as a document in theindex.html
  sed -E -i $indexFile -e "s/nimTitle/markupTitle/"
done

# Now build the documentation
nimble -y doc \
    --project \
    --outdir="${{ inputs.out-dir }}" \
    --index:on \
    --git.url:"$GITHUB_SERVER_URL/$GITHUB_REPOSITORY" \
    --git.commit:"${{ steps.get-version.outputs.pkg_ver || github.sha }}" \
    --git.devel:"${{ inputs.devel-branch || github.event.repository.default_branch }}" \
    -d:docgen \
    $3
