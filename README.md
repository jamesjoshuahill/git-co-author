# git-co-author

Attribute a commit to a pair or mob of co-authors.

This command adds one or more `Co-authored-by` trailers to the Git commit template. Co-authored commits are displayed on GitHub.

For more information on co-authoring commits, see [Git Together By Co-Authoring Commits](https://github.community/t5/Support-Protips/Git-Together-By-Co-Authoring-Commits/ba-p/27480).

This command has no dependencies. It was inspired by [`git-author`](https://github.com/pivotal/git-author).

## Get started

Install the command:

```bash
install git-co-author /usr/local/bin/
```

Set the location of the commit template:

```bash
git config --global commit.template '~/.git-template'
```

Set up a co-author with their initials, name and email address:

```bash
git config --global co-authors.aa 'Ann Author <aauthor@users.noreply.github.com>'
```

You must use the email address associated with your GitHub account. For more information, see [Setting your commit email address](https://help.github.com/en/github/setting-up-and-managing-your-github-user-account/setting-your-commit-email-address#setting-your-commit-email-address-on-github).

Set co-authors in the commit template:

```bash
git co-author aa        # solo
git co-author aa bb     # pair
git co-author aa bb cc  # mob
```
