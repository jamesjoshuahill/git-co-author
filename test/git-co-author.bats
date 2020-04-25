#!/usr/bin/env bats

setup() {
  PATH="$BATS_TEST_DIRNAME/..:$PATH"

  test_dir="$BATS_TMPDIR/$BATS_TEST_NAME"
  template_file="$test_dir/.git-template"

  rm -rf "$test_dir"
  mkdir -p "$test_dir"
  cd "$test_dir" || exit 1

  git init
  git config --local commit.template "$template_file"
  git config --local co-authors.aa 'Ann Author <ann.author@example.com>'
  git config --local co-authors.bb 'Bob Book <bob.book@example.com>'
  touch "$template_file"
}

teardown() {
  rm -rf "$test_dir"
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

@test "--help option prints usage" {
  run git-co-author --help
  [ $status -eq 1 ]
  [ "${lines[0]}" = "Easily add 'Co-authored-by' trailers to the commit template." ]
}

@test "-h option prints usage" {
  run git-co-author -h
  [ $status -eq 1 ]
  [ "${lines[0]}" = "Easily add 'Co-authored-by' trailers to the commit template." ]
}

@test "--clear option removes all Co-authored-by trailers" {
  echo "

Co-authored-by: Ann Author <ann.author@example.com>
Co-authored-by: Bob Book <bob.book@example.com>" > "$template_file"

  run git-co-author --clear
  [ $status -eq 0 ]
  [ "$output" = "" ]
  run grep "Co-authored-by" "$template_file"
  [ $status -eq 1 ]
}

@test "--clear option does not modify rest of commit template" {
  echo "Some text

Co-authored-by: Ann Author <ann.author@example.com>
Some-token: some value
Co-authored-by: Bob Book <bob.book@example.com>
Another-token: another value" > "$template_file"

  run git-co-author --clear
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

@test "--clear option prints error when commit template is blank" {
  git config --local commit.template ""

  run git-co-author --clear
  [ $status -eq 1 ]
  [ "${lines[0]}" = "commit template is not configured" ]
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
  echo "$output"
  [ "$output" = "Co-authored-by: Bob Book <bob.book@example.com>" ]
  run cat "$template_file"
  [ $status -eq 0 ]
  [ "$output" = "Some text

Some-token: some value
Another-token: another value
Co-authored-by: Bob Book <bob.book@example.com>" ]
}

@test "prints error when adding an unknown co-author" {
  run git-co-author ee
  [ $status -eq 1 ]
  [ "${lines[0]}" = "co-author 'ee' is not configured" ]
}

@test "does not modify commit template when adding an unknown co-author" {
  echo "Some text

Co-authored-by: Ann Author <ann.author@example.com>" > "$template_file"

  run git-co-author ee
  [ $status -eq 1 ]
  run cat "$template_file"
  [ $status -eq 0 ]
  [ "$output" = "Some text

Co-authored-by: Ann Author <ann.author@example.com>" ]
}

@test "add co-author prints error when commit template is blank" {
  git config --local commit.template ""

  run git-co-author aa
  [ $status -eq 1 ]
  [ "${lines[0]}" = "commit template is not configured" ]
}
