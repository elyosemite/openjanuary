# OpenJanuary

**A calm project manager that lives where you already work: your terminal.**

Work, university, personal life, finances, open source. Everything competes for your attention, and most tools built to tame it pull you out of the place where you spend your day. OpenJanuary keeps your boards one command away. It is written in Ruby, stores plain files on your machine, and asks for nothing else.

```
Project: open-source    Board: main    Era: Autumn Release

Backlog (2)            Doing (2)              Review (1)             Done (3)
--------------------   --------------------   --------------------   --------------------
#12 Triage issues      #8 Fix parser crash    #5 Add --json flag     #1 Init repo
#14 Write docs         #11 Release notes                             #2 CI setup
                                                                     #3 Add license
```

## Highlights

- **Terminal native.** No browser, no account, no sync dialog.
- **Deliberately simple.** A card has a title and a description. Nothing more.
- **Separate worlds.** Projects keep open source cards away from finance cards.
- **Boards inside projects.** Each project can hold several boards, one per set of activities.
- **Your columns.** Add, remove and reorder them to fit how you work.
- **Time boxed.** Eras give you a sprint-like rhythm without the ceremony.
- **Plain files.** Everything is YAML on disk, easy to read, back up and version.

## Status

Everything described below works today. Interactive mode and Markdown export are still on the roadmap.

## Installation

Requires Ruby 3.2 or newer.

```sh
git clone https://github.com/your-user/openjanuary.git
cd openjanuary
bundle install
bin/january help
```

On Windows, use `bin\january` (a launcher is included). In PowerShell, run `.\bin\january`.

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

A full first session looks like this:

```sh
january project add work
january board add studies    # optional: a second board
january board era start November --ends 2026-11-30
january board card add "Write the proposal" -d "Draft and send to the team"
january board card move 1 Doing
january board
```

## Concepts

| Concept | What it is |
| --- | --- |
| **Project** | An isolated area that holds one or more boards. Use one per area of life, such as `work`, `college`, `finances` or `open-source`. |
| **Board** | A set of activities inside a project, with its own columns, cards and eras. Every board belongs to exactly one project, and a new project starts with a board called `main`. Every new board comes with the columns Backlog, Doing and Done. |
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

Columns belong to a board, so these commands act on the active board. Every new board starts with Backlog, Doing and Done, which you can change freely.

```sh
january board column add NAME            # add a column at the end
january board column list               # list columns in order
january board column remove NAME         # remove a column
```

Column names are case insensitive for matching, and keep the case you typed.

Removing a column that still has cards is blocked. Pass `--move-to COLUMN` to relocate the cards or `--force` to delete them with the column.

### Cards

Cards belong to a board and always sit in one of its columns, so these commands act on the active board. Ids are sequential per project and are never reused.

```sh
january board card add "Pay the university fee" --column Backlog \
  --description "Due on the 10th, bank transfer"
january board card list [--column NAME]
january board card show 7
january board card move 7 Doing
january board card edit 7                      # opens $EDITOR
january board card edit 7 --title "New title"  # or edit with flags
january board card remove 7
```

Without `--column`, a new card goes to the first column (Backlog on a default board). When editing in your editor, the first line is the title and everything after the blank line is the description.

### Eras

An era is a time boxed period of a board. Only one era can be active per board, and new cards join it automatically.

```sh
january board era start "November" --ends 2026-11-30
january board era current
january board era close [--carry | --backlog]
```

The last column counts as done. When you close an era with unfinished cards, you choose what happens to them: `--carry` moves them into the next era you start, and `--backlog` sends them back to the first column. Without a flag, you are asked.

### Boards

A project can have several boards. Columns, cards and eras always belong to the active board of the active project, and each project remembers which board was active.

```sh
january board add NAME          # create a board in the active project
january board list              # list boards, active one marked with *
january board use NAME          # switch the active board
january board remove NAME       # delete a board (asks first, or pass --yes)
```

A project always keeps at least one board. Card ids and eras are per board.

#### Acting on a specific board

Columns, cards and eras live inside a board. Their commands act on the active board by default, and `--board NAME` (or `-b NAME`) targets another board without switching:

```sh
january board column add Reading --board studies
january board card add "Chapter 1" -b studies
january board card list -b studies
january board era start Semester -b studies
```

### Board view

```sh
january board                    # active board, current era
january board --all              # every card, regardless of era
january board move NAME --to N   # move a column to position N (starting at 1)
```

With no active era, the board shows every card. Columns are laid out side by side and stacked on narrow terminals. Titles that do not fit are truncated.

## Data

Everything is stored locally, one file per project.

```
~/.january/
  config.yml            # active project
  projects/
    finances.yml        # one file per project, with all of its boards
    open-source.yml
```

Project files written by earlier versions are upgraded on read: their columns, cards and eras become the `main` board.

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
- [x] Board rendering
- [x] Eras
- [ ] Interactive mode with keyboard navigation
- [ ] Export to Markdown

## Contributing

Issues and pull requests are welcome. Keep changes small and focused, add tests for new behavior, and prefer simplicity over features.

## License

MIT
