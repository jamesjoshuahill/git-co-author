#!/usr/bin/env bats

setup() {
  PATH="$BATS_TEST_DIRNAME/..:$PATH"

  test_dir="$BATS_TMPDIR/test-git-co-author"
  template_file="$test_dir/test-commit-template"
  template_file_in_home="$HOME/test-commit-template"

  mkdir -p "$test_dir"
  cd "$test_dir" || exit 1
  rm -rf .git/

  git init
  git config --local commit.template "$template_file"
  git config --local user.name 'Ann Author'
  git config --local user.email 'ann.author@example.com'
  git config --local co-authors.aa 'Ann Author <ann.author@example.com>'
  git config --local co-authors.bb 'Bob Book <bob.book@example.com>'
  git config --local --unset co-authors.ab || true
  git config --local --unset co-authors.bb-2 || true

  touch "$template_file"
  touch "$template_file_in_home"
}

teardown() {
  rm -rf "$template_file"
  rm "$template_file_in_home"
}

@test "no arguments prints nothing when there are no co-authors" {
  run git-co-author
  [ $status -eq 0 ]
  [ "$output" = "" ]
}

@test "no arguments prints co-author trailers when there are co-authors" {
  echo "

Some-token: some value
Co-authored-by: Ann Author <ann.author@example.com>
Co-authored-by: Bob Book <bob.book@example.com>" > "$template_file"

  run git-co-author
  [ $status -eq 0 ]
  [ "$output" = "Co-authored-by: Ann Author <ann.author@example.com>
Co-authored-by: Bob Book <bob.book@example.com>" ]
}

@test "no arguments prints nothing when there is no commit template" {
  rm "$template_file"

  run git-co-author
  [ $status -eq 0 ]
  [ "$output" = "" ]
}

@test "no arguments prints error when commit template is blank" {
  git config --local commit.template ""

  run git-co-author
  [ $status -eq 1 ]
  [ "${lines[0]}" = "commit template is not configured" ]
}

@test "no arguments prints error when commit template is not configured" {
  git config --local --unset commit.template

  run git-co-author
  [ $status -eq 1 ]
  [ "${lines[0]}" = "commit template is not configured" ]
}

@test "-h option prints usage" {
  run git-co-author -h
  [ $status -eq 0 ]
  [[ "${lines[0]}" =~ ^usage:.* ]]
}

@test "-h option does not modify commit template" {
  echo "Some text

Co-authored-by: Ann Author <ann.author@example.com>
Some-token: some value
Co-authored-by: Bob Book <bob.book@example.com>
Another-token: another value" > "$template_file"

  run git-co-author -h
  [ $status -eq 0 ]
  run cat "$template_file"
  [ $status -eq 0 ]
  [ "$output" = "Some text

Co-authored-by: Ann Author <ann.author@example.com>
Some-token: some value
Co-authored-by: Bob Book <bob.book@example.com>
Another-token: another value" ]
}

@test "-h option at end of arguments prints usage" {
  run git-co-author aa bb -h
  [ $status -eq 0 ]
  [[ "${lines[0]}" =~ ^usage:.* ]]
}

@test "-h option after a subcommand prints usage" {
  run git-co-author clear -h
  [ $status -eq 0 ]
  [[ "${lines[0]}" =~ ^usage:.* ]]
}

@test "-h option amongst arguments prints usage" {
  run git-co-author aa -h bb
  [ $status -eq 0 ]
  [[ "${lines[0]}" =~ ^usage:.* ]]
}

@test "-h option prints usage when commit template is blank" {
  git config --local commit.template ""

  run git-co-author -h
  [ $status -eq 0 ]
  [[ "${lines[0]}" =~ ^usage:.* ]]
}

@test "-h option prints usage when commit template is not configured" {
  git config --local --unset commit.template

  run git-co-author -h
  [ $status -eq 0 ]
  [[ "${lines[0]}" =~ ^usage:.* ]]
}

@test "clear subcommand succeeds when there are no Co-authored-by trailers" {
  run git-co-author clear
  [ $status -eq 0 ]
  [ "$output" = "" ]
}

@test "clear subcommand removes all Co-authored-by trailers" {
  echo "

Co-authored-by: Ann Author <ann.author@example.com>
Co-authored-by: Bob Book <bob.book@example.com>" > "$template_file"

  run git-co-author clear
  [ $status -eq 0 ]
  [ "$output" = "" ]
  run grep "Co-authored-by" "$template_file"
  [ $status -eq 1 ]
}

@test "clear subcommand does not modify rest of commit template" {
  echo "Some text

Co-authored-by: Ann Author <ann.author@example.com>
Some-token: some value
Co-authored-by: Bob Book <bob.book@example.com>
Another-token: another value" > "$template_file"

  run git-co-author clear
  [ $status -eq 0 ]
  [ "$output" = "" ]
  run grep "Co-authored-by" "$template_file"
  [ $status -eq 1 ]
  run cat "$template_file"
  [ $status -eq 0 ]
  [ "$output" = "Some text

Some-token: some value
Another-token: another value" ]
}

@test "clear subcommand prints error when commit template is blank" {
  git config --local commit.template ""

  run git-co-author clear
  [ $status -eq 1 ]
  [ "${lines[0]}" = "commit template is not configured" ]
}

@test "clear subcommand prints error when commit template not configured" {
  git config --local --unset commit.template

  run git-co-author clear
  [ $status -eq 1 ]
  [ "${lines[0]}" = "commit template is not configured" ]
}

@test "authors subcommand prints authors in config" {
  git config --local co-authors.ab 'Anna Book <anna.book@example.com>'
  git config --local co-authors.bb-2 'Bobby Book <bobby.book@example.com>'

  run git-co-author authors
  [ $status -eq 0 ]
  [ "$output" = "aa    'Ann Author <ann.author@example.com>'
ab    'Anna Book <anna.book@example.com>'
bb    'Bob Book <bob.book@example.com>'
bb-2  'Bobby Book <bobby.book@example.com>'" ]
}

@test "authors subcommand prints message when there are none" {
  git config --local --unset co-authors.aa
  git config --local --unset co-authors.bb

  run git-co-author authors
  [ $status -eq 0 ]
  [ "${lines[0]}" = "No authors in config." ]
}

@test "find sumcommand prints errors when not in a git repository" {
  rm -rf .git/

  run git co-author find
  [ $status -eq 128 ]
  [[ "${lines[0]}" =~ ^fatal:.* ]]
}

@test "find subcommand prints error when there are no commits" {
  run git co-author find
  [ $status -eq 128 ]
  [[ "${lines[0]}" =~ ^fatal:.* ]]
}

@test "find subcommand prints authors in git log" {
  git commit --allow-empty -m'Test'
  git commit --allow-empty -m'Test' --author="Bob Book <bob.book@example.com>"

  run git co-author find
  [ $status -eq 0 ]
  [ "$output" = "Ann Author <ann.author@example.com>
Bob Book <bob.book@example.com>" ]
}

@test "find subcommand prints co-authors in git log" {
  git commit --allow-empty -m'Test

Co-authored-by: Bob Book <bob.book@example.com>'
  git commit --allow-empty -m'Test

Co-authored-by: Anna Book <anna.book@example.com>'

  run git co-author find
  [ $status -eq 0 ]
  [ "$output" = "Ann Author <ann.author@example.com>
Anna Book <anna.book@example.com>
Bob Book <bob.book@example.com>" ]
}

@test "find subcommand does not print other trailers in git log" {
  git commit --allow-empty -m"Test

Some-token: some value
Another-token: another value"

  run git co-author find
  [ $status -eq 0 ]
  [ "$output" = "Ann Author <ann.author@example.com>" ]
}

@test "adds a co-author" {
  run git-co-author aa
  [ $status -eq 0 ]
  [ "$output" = "Co-authored-by: Ann Author <ann.author@example.com>" ]
  run cat "$template_file"
  [ $status -eq 0 ]
  [ "$output" = "
Co-authored-by: Ann Author <ann.author@example.com>" ]
}

@test "adds two co-authors" {
  run git-co-author aa bb
  [ $status -eq 0 ]
  [ "$output" = "Co-authored-by: Ann Author <ann.author@example.com>
Co-authored-by: Bob Book <bob.book@example.com>" ]
  run cat "$template_file"
  [ $status -eq 0 ]
  [ "$output" = "
Co-authored-by: Ann Author <ann.author@example.com>
Co-authored-by: Bob Book <bob.book@example.com>" ]
}

@test "changing co-author does not modify rest of commit template" {
  echo "Some text

Co-authored-by: Ann Author <ann.author@example.com>
Some-token: some value
Another-token: another value" > "$template_file"

  run git-co-author bb
  [ $status -eq 0 ]
  [ "$output" = "Co-authored-by: Bob Book <bob.book@example.com>" ]
  run cat "$template_file"
  [ $status -eq 0 ]
  [ "$output" = "Some text

Some-token: some value
Another-token: another value
Co-authored-by: Bob Book <bob.book@example.com>" ]
}

@test "adding an unknown co-author prints error" {
  run git-co-author ee
  [ $status -eq 1 ]
  [ "${lines[0]}" = "co-author 'ee' is not configured" ]
}

@test "adding a subcommand prints error" {
  run git-co-author aa clear
  [ $status -eq 1 ]
  [ "${lines[0]}" = "co-author 'clear' is not configured" ]
}

@test "adding an unknown co-author does not modify commit template" {
  echo "Some text

Co-authored-by: Ann Author <ann.author@example.com>" > "$template_file"

  run git-co-author ee
  [ $status -eq 1 ]
  run cat "$template_file"
  [ $status -eq 0 ]
  [ "$output" = "Some text

Co-authored-by: Ann Author <ann.author@example.com>" ]
}

@test "adding an invalid co-author prints error" {
  run git-co-author 1
  [ $status -eq 1 ]
  [ "${lines[0]}" = "co-author '1' is not configured" ]
}

@test "adding co-author when commit template is blank prints error" {
  git config --local commit.template ""

  run git-co-author aa
  [ $status -eq 1 ]
  [ "${lines[0]}" = "commit template is not configured" ]
}

@test "adding co-author when commit template is not configured prints error" {
  git config --local --unset commit.template

  run git-co-author aa
  [ $status -eq 1 ]
  [ "${lines[0]}" = "commit template is not configured" ]
}

@test "adding a co-author when the commit template includes a ~" {
  # shellcheck disable=SC2088
  git config --local commit.template '~/test-commit-template'

  run git-co-author aa
  [ $status -eq 0 ]
  [ "$output" = "Co-authored-by: Ann Author <ann.author@example.com>" ]
  run cat "$template_file_in_home"
  [ $status -eq 0 ]
  [ "$output" = "
Co-authored-by: Ann Author <ann.author@example.com>" ]
}
