# border.fish

A [fish](https://fishshell.com/) plugin that draws a border after each run command.
The border is only drawn if the command takes longer than `BORDER_MIN_CMD_DURATION` milliseconds to execute, or if the terminal has more than `BORDER_MIN_COLUMNS` columns.
If the previous command exceeds `BORDER_MIN_CMD_DURATION` milliseconds, the border will be drawn and the duration of the command will be displayed in the border.
If the previous command exited with a non-zero status, the border will be drawn in red, and the exit status will be displayed in the border.
If the previous command was not found in the `$PATH`, the border will be drawn in yellow.

## Installation

```fish
fisher install kpbaks/border.fish
```

## Customization

The following variables can be changed to customize the plugin:

| Variable                  | Default | Description                                                  | Constraints                                                                        |
| ------------------------- | ------- | ------------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| `BORDER_DELIM`            | `─`     | The character used to draw the border                        | Must have a length of 1                                                            |
| `BORDER_MIN_CMD_DURATION` | `5000`  | The minimum duration of a command before the border is drawn | Must be a positive integer                                                         |
| `BORDER_MIN_COLUMNS`      | `80`    | The minimum number of columns before the border is drawn     | Must be a positive integer                                                         |
| `BORDER_ALIGNMENT`        | `0.5`   | The alignment of the border                                  | Must be one of: `left`, `center`, `right`, or a percentage between `0.0` and `1.0` |

## Screenshot

TODO
