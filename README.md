# git-co-author

Easily add `Co-authored-by` trailers to the commit template.

```bash
git co-author initials...
```

This command enables pairs and mobs of programmers to attribute commits to all the authors. For convenience, co-authors are added using their initials.

GitHub has first-class support for `Co-authored-by` trailers and recognises the author and co-authors of commits. For more information on co-authoring commits see:
- [Git Together By Co-Authoring Commits](https://github.community/t5/Support-Protips/Git-Together-By-Co-Authoring-Commits/ba-p/27480)
- [Creating a commit with multiple authors](https://help.github.com/en/github/committing-changes-to-your-project/creating-a-commit-with-multiple-authors)

## Install

Install the command:

```bash
install git-co-author /usr/local/bin/
```

Configure the commit template path:

```bash
git config --global commit.template '~/.git-template'
```

Ensure there is a commit template file:

```bash
touch '~/.git-template'
```

## Configure co-authors

Configure a co-author using their initials. For example 'aa' and 'bb':

```bash
git config --global co-authors.aa 'Ann Author <ann.author@example.com>'
git config --global co-authors.bb 'Bob Book <bob.book@example.com>'
```

You must use the email address associated with your GitHub account, see [Setting your commit email address](https://help.github.com/en/github/setting-up-and-managing-your-github-user-account/setting-your-commit-email-address#setting-your-commit-email-address-on-github).

## Usage

Pair:

```bash
$ git co-author aa
Co-authored-by: Ann Author <ann.author@example.com>
$ git commit
```

Mob:

```bash
$ git co-author aa bb
Co-authored-by: Ann Author <ann.author@example.com>
Co-authored-by: Bob Book <bob.book@example.com>
$ git commit
```

Solo:

```bash
$ git co-author --clear
$ git commit
```

:warning: If the commit message is given using `git commit -m "Message"` the commit template is not used, so `Co-authored-by` trailers may be missing from the commit.

## Notes

- Assumes the user has configured `user.name` and `user.email` so that they are attributed as an author.
- Does not modify Git config.
- Config in the current Git repo takes precedence over global Git config.
- Only the `Co-authored-by` trailers in the commit template file are modified or removed. The rest of the commit template is unaffected.
- Inspired by [`git-author`](https://github.com/pivotal/git-author).
