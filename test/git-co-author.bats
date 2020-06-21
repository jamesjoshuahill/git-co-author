#!/usr/bin/env bats

setup() {
  PATH="$BATS_TEST_DIRNAME/..:$PATH"

  test_dir="$BATS_TMPDIR/$BATS_TEST_NAME"
  template_file="$test_dir/test-commit-template"
  template_file_in_home="$HOME/test-commit-template"

  rm -rf "$test_dir"
  mkdir -p "$test_dir"
  cd "$test_dir" || exit 1

  git init
  git config --local commit.template "$template_file"
  git config --local co-authors.aa 'Ann Author <ann.author@example.com>'
  git config --local co-authors.bb 'Bob Book <bob.book@example.com>'

  touch "$template_file"
  touch "$template_file_in_home"
}

teardown() {
  rm -rf "$test_dir"
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

@test "--help option prints usage" {
  run git-co-author --help
  [ $status -eq 0 ]
  [ "${lines[0]}" = "Easily add 'Co-authored-by' trailers to the commit template." ]
}

@test "-h option prints usage" {
  run git-co-author -h
  [ $status -eq 0 ]
  [ "${lines[0]}" = "Easily add 'Co-authored-by' trailers to the commit template." ]
}

@test "--help option does not modify commit template" {
  echo "Some text

Co-authored-by: Ann Author <ann.author@example.com>
Some-token: some value
Co-authored-by: Bob Book <bob.book@example.com>
Another-token: another value" > "$template_file"

  run git-co-author --help
  [ $status -eq 0 ]
  run cat "$template_file"
  [ $status -eq 0 ]
  [ "$output" = "Some text

Co-authored-by: Ann Author <ann.author@example.com>
Some-token: some value
Co-authored-by: Bob Book <bob.book@example.com>
Another-token: another value" ]
}

@test "--help option at end of arguments prints usage" {
  run git-co-author aa bb --help
  [ $status -eq 0 ]
  [ "${lines[0]}" = "Easily add 'Co-authored-by' trailers to the commit template." ]
}

@test "--help option amongst arguments prints usage" {
  run git-co-author aa --help bb
  [ $status -eq 0 ]
  [ "${lines[0]}" = "Easily add 'Co-authored-by' trailers to the commit template." ]
}

@test "--help option prints usage when commit template is blank" {
  git config --local commit.template ""

  run git-co-author --help
  [ $status -eq 0 ]
  [ "${lines[0]}" = "Easily add 'Co-authored-by' trailers to the commit template." ]
}

@test "--clear option succeeds when there are no Co-authored-by trailers" {
  run git-co-author --clear
  [ $status -eq 0 ]
  [ "$output" = "" ]
}

@test "--clear option at end of arguments succeeds" {
  run git-co-author aa --clear
  [ $status -eq 0 ]
  [ "$output" = "" ]
  run grep "Co-authored-by" "$template_file"
  [ $status -eq 1 ]
}

@test "--clear option amongst arguments succeeds" {
  run git-co-author aa --clear bb
  [ $status -eq 0 ]
  [ "$output" = "" ]
  run grep "Co-authored-by" "$template_file"
  [ $status -eq 1 ]
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
