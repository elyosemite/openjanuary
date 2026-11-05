# OpenJanuary

**A calm, keyboard-first project manager that lives in your terminal.**

Work, university, personal life, finances, open source. Everything competes for your attention, and most tools built to tame it pull you out of the place where you already spend your day. OpenJanuary keeps your boards one command away, written in Ruby, with nothing between you and your cards.

```
 Project: open-source                                  Era: Autumn Release
 ------------------------------------------------------------------------
  Backlog (3)          Doing (2)            Review (1)         Done (4)
 ----------------    ----------------    ----------------    ----------------
  #12 Triage          #08 Fix parser      #05 Add --json     #01 Init repo
      issues              crash               flag           #02 CI setup
  #14 Write docs      #11 Release         
  #15 Plan v2             notes                              
```

## Status

OpenJanuary is in its early days. This README describes the intended design and the commands listed below are the target interface. Expect details to change while the first version takes shape.

## Why

- **Terminal native.** No browser tab, no account, no sync dialog.
- **Simple on purpose.** A card has a title and a description. That is all.
- **Separated worlds.** Projects keep your open source cards away from your finance cards.
- **Time boxed.** Eras give you a sprint-like rhythm without the ceremony.

## Concepts

| Concept | What it is |
| --- | --- |
| **Project** | An isolated board. Use one per area of life, such as `work`, `college`, `finances` or `open-source`. |
| **Column** | A lane of the board, such as Backlog, Doing or Done. You can add, remove and reorder columns freely. |
| **Card** | A unit of work with a title and a description. Nothing more. |
| **Era** | A time boxed period, similar to a sprint in Jira. Cards are planned into an era and reviewed when it ends. |

## Installation

Requires Ruby 3.2 or newer.

```sh
git clone https://github.com/your-user/openjanuary.git
cd openjanuary
bundle install
bin/january help
```

## Usage

### Projects

```sh
january project add finances
january project list
january project use finances
january project remove finances
```

### Columns

```sh
january column add "Backlog"
january column add "Doing"
january column add "Done"
january column move "Done" --to 1
january column remove "Doing"
```

### Cards

```sh
january card add "Pay the university fee" --column Backlog \
  --description "Due on the 10th, bank transfer"
january card list
january card show 7
january card move 7 Doing
january card edit 7
january card remove 7
```

### Eras

```sh
january era start "November" --ends 2026-11-30
january era current
january era close
```

### Board view

```sh
january board
```

Prints the active project as columns, filtered to the current era.

## Data

Everything is stored locally, one file per project, so you can inspect it, back it up or keep it in version control.

```
~/.january/
  config.yml
  projects/
    finances.yml
    open-source.yml
```

## Roadmap

- [ ] Projects, columns, cards and eras
- [ ] Board rendering in the terminal
- [ ] Interactive mode with keyboard navigation
- [ ] Export to Markdown

## Contributing

Issues and pull requests are welcome. Keep changes small and focused, and prefer simplicity over features.

## License

MIT
