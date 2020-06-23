# git-co-author

Easily add `Co-authored-by` trailers to the commit template.

```bash
Usage:
  git co-author              Show co-author trailers
  git co-author initials...  Update co-author trailers
  git co-author --clear      Remove all co-author trailers
  git co-author --authors    List configured authors
  git co-author --help       Show help
```

This command enables pairs and mobs of programmers to attribute commits to all the authors. For convenience, co-authors are added using their initials. Their names and email addresses are stored in git config.

GitHub has first-class support for `Co-authored-by` trailers and recognises the author and co-authors of commits. For more information on co-authoring commits, see:

- [Git Together By Co-Authoring Commits](https://github.community/t5/Support-Protips/Git-Together-By-Co-Authoring-Commits/ba-p/27480)
- [Creating a commit with multiple authors](https://help.github.com/en/github/committing-changes-to-your-project/creating-a-commit-with-multiple-authors)

## Install

Install the command:

```bash
install git-co-author /usr/local/bin/
```

Configure the commit template path, for example:

```bash
git config --global commit.template '~/.git-commit-template'
```

Ensure there is a commit template file:

```bash
touch '~/.git-commit-template'
```

## Configure co-authors

Configure the name and email address of co-authors with their initials. For example 'aa' and 'bb':

```bash
git config --global co-authors.aa 'Ann Author <ann.author@example.com>'
git config --global co-authors.bb 'Bob Book <bob.book@example.com>'
```

You must use an email address associated with the co-author's GitHub account.

**Tip:** You can help a co-author find their preferred email address by sharing this information:

- To find your GitHub-provided `no-reply` email, navigate to your email settings page under "Keep my email address private."
- To find the email you used to configure Git on your computer, run `git config user.email` on the command line.

## Usage

Pair with a co-author:

```bash
$ git co-author aa
Co-authored-by: Ann Author <ann.author@example.com>
$ git commit
```

Mob with two or more co-authors:

```bash
$ git co-author aa bb
Co-authored-by: Ann Author <ann.author@example.com>
Co-authored-by: Bob Book <bob.book@example.com>
$ git commit
```

Solo without co-authors:

```bash
$ git co-author --clear
$ git commit
```

If the commit message is given using `git commit -m "Message"` the commit template is not used, so `Co-authored-by` trailers may be missing from the commit.

List authors in config:

```bash
$ git co-author --authors
aa  'Ann Author <ann.author@example.com>'
bb  'Bob Book <bob.book@example.com>'
```

## Test

The command is tested using the [Bats](https://github.com/sstephenson/bats) testing framework for Bash.

Install Bats:

```bash
brew install bats
```

Run tests:

```bash
./test/git-co-author.bats
```

## Notes

- The command does not modify Git config.
- This approach assumes the user has configured `user.name` and `user.email` so that they are attributed as an author.
- Only the `Co-authored-by` trailers in the commit template file are modified or removed. The rest of the commit template is unaffected.
- GitHub deduplicates multiple authors of a commit, so if you commit as author and co-author you will only be shown once.
- Config in the current Git repo takes precedence over global Git config. To set config for one repo use the `git config --local` option.
- Inspired by [`git-author`](https://github.com/pivotal/git-author).
