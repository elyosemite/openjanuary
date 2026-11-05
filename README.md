# OpenJanuary

**A calm project manager that lives where you already work: your terminal.**

Work, university, personal life, finances, open source. Everything competes for your attention, and most tools built to tame it pull you out of the place where you spend your day. OpenJanuary keeps your boards one command away. It is written in Ruby, stores plain files on your machine, and asks for nothing else.

```
 Project: open-source                                  Era: Autumn Release
 -------------------------------------------------------------------------
  Backlog (3)         Doing (2)           Review (1)         Done (4)
 ----------------   ----------------   ----------------   ----------------
  #12 Triage          #08 Fix parser     #05 Add --json     #01 Init repo
      issues              crash              flag           #02 CI setup
  #14 Write docs      #11 Release                           #03 Add license
  #15 Plan v2             notes                             #04 Draft README
```

> The board above is the target design. See [Status](#status) for what works today.

## Highlights

- **Terminal native.** No browser, no account, no sync dialog.
- **Deliberately simple.** A card has a title and a description. Nothing more.
- **Separate worlds.** Projects keep open source cards away from finance cards.
- **Your columns.** Add, remove and reorder them to fit how you work.
- **Time boxed.** Eras give you a sprint-like rhythm without the ceremony.
- **Plain files.** Everything is YAML on disk, easy to read, back up and version.

## Status

OpenJanuary is under active development. The first version is built one feature at a time.

| Feature | State |
| --- | --- |
| Projects (`add`, `list`, `use`, `remove`) | Available |
| Columns (`add`, `list`, `remove`, `move`) | Available |
| Cards (`add`, `list`, `show`, `move`, `edit`, `remove`) | Available |
| Board view | Planned |
| Eras | Planned |

Sections below marked as planned describe the intended interface and may change.

## Installation

Requires Ruby 3.2 or newer.

```sh
git clone https://github.com/your-user/openjanuary.git
cd openjanuary
bundle install
bin/january help
```

To call it as `january` from anywhere, add the `bin` directory to your `PATH`.

## Quick start

```sh
january project add finances
january project add open-source
january project use open-source
january project list
```

```
  finances
* open-source
```

The asterisk marks the active project. The first project you create becomes active automatically.

## Concepts

| Concept | What it is |
| --- | --- |
| **Project** | An isolated board. Use one per area of life, such as `work`, `college`, `finances` or `open-source`. |
| **Column** | A lane of the board, such as Backlog, Doing or Done. You can add, remove and reorder them. |
| **Card** | A unit of work with a title and a description. |
| **Era** | A time boxed period, similar to a sprint in Jira. Cards are planned into an era and reviewed when it ends. |

## Commands

### Projects

```sh
january project add NAME       # create a project
january project list           # list projects, active one marked with *
january project use NAME       # switch the active project
january project remove NAME    # delete a project (asks first, or pass --yes)
```

Project names are lowercase and may contain letters, digits, `-` and `_`.

### Columns

Columns belong to the active project.

```sh
january column add NAME            # add a column at the end
january column list               # list columns in order
january column move NAME --to N   # move to position N (starting at 1)
january column remove NAME         # remove a column
```

Column names are case insensitive for matching, and keep the case you typed.

Removing a column that still has cards is blocked. Pass `--move-to COLUMN` to relocate the cards or `--force` to delete them with the column.

### Cards

Cards belong to the active project and always sit in a column. Ids are sequential per project and are never reused.

```sh
january card add "Pay the university fee" --column Backlog \
  --description "Due on the 10th, bank transfer"
january card list [--column NAME]
january card show 7
january card move 7 Doing
january card edit 7                      # opens $EDITOR
january card edit 7 --title "New title"  # or edit with flags
january card remove 7
```

Without `--column`, a new card goes to the first column. When editing in your editor, the first line is the title and everything after the blank line is the description.

### Eras (planned)

```sh
january era start "November" --ends 2026-11-30
january era current
january era close
```

### Board (planned)

```sh
january board           # active project, current era
january board --all     # every card, regardless of era
```

## Data

Everything is stored locally, one file per project.

```
~/.january/
  config.yml            # active project
  projects/
    finances.yml
    open-source.yml
```

Set `JANUARY_HOME` to keep your data somewhere else, for example inside a synced folder or a git repository:

```sh
export JANUARY_HOME=~/notes/january
```

Writes are atomic, so a crash in the middle of saving never leaves a half written file.

## Development

```sh
bundle install
bundle exec rake test
```

The code is split in two layers. The domain and storage live in `lib/january/` and know nothing about the command line. The commands live in `lib/january/cli/` and only parse arguments and print results. This keeps room for an interactive mode later without rewriting the rules.

## Roadmap

- [x] Projects
- [x] Columns
- [x] Cards
- [ ] Board rendering
- [ ] Eras
- [ ] Interactive mode with keyboard navigation
- [ ] Export to Markdown

## Contributing

Issues and pull requests are welcome. Keep changes small and focused, add tests for new behavior, and prefer simplicity over features.

## License

MIT
