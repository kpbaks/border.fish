# set -l delim ━
# set -l DELIM ─
# set -l delim ═
# set -l delim -
# set -l delim _
set --global __BORDER_DELIM_DEFAULT ─
set --global __BORDER_MIN_CMD_DURATION_DEFAULT 5000 # ms
set --global __BORDER_MIN_COLUMNS_DEFAULT 80
set --global __BORDER_ALIGNMENT_DEFAULT 0.5

function _border.fish_install --on-event border.fish_install
    # Set universal variables, create bindings, and other initialization logic.
    contains -- kpbaks/peopletime.fish (fisher list)
    or fisher install kpbaks/peopletime.fish

    set -l yellow (set_color yellow)
    set -l blue (set_color blue)
    set -l reset (set_color normal)
    set -l count 40
    set -l indent (string repeat --count 4 --no-newline " ")
    printf "%s %sborder.fish%s %s\n" \
        (string repeat --count $count --no-newline "-") \
        $blue $reset \
        (string repeat --count $count --no-newline "-")

    printf "The following variables are available for customization:\n"
    printf "%sBORDER_DELIM%s %s\n" $yellow $reset $__BORDER_DELIM_DEFAULT
    printf "%s(%sNOTE:%s must have a length of 1)\n" $indent $blue $reset
    printf "%sBORDER_MIN_CMD_DURATION%s %s\n" $yellow $reset $__BORDER_MIN_CMD_DURATION_DEFAULT
    printf "%s(%sNOTE:%s unit is milliseconds and must be a positive integer)\n" $indent $blue $reset
    printf "%sBORDER_MIN_COLUMNS%s %s\n" $yellow $reset $__BORDER_MIN_COLUMNS_DEFAULT
    printf "%s(%sNOTE:%s must be a positive integer)\n" $indent $blue $reset
    printf "%sBORDER_ALIGNMENT%s %s\n" $yellow $reset $__BORDER_ALIGNMENT_DEFAULT
    printf "%s(%sNOTE:%s must be one of: left, center, right, or a percentage between 0.0 and 1.0)\n" $indent $blue $reset
end

function _border.fish_update --on-event border.fish_update
    # Migrate resources, print warnings, and other update logic.
end

function _border.fish_uninstall --on-event border.fish_uninstall
    # Erase "private" functions, variables, bindings, and other uninstall logic.
end

status is-interactive; or return

set --query BORDER_DELIM; or set --global BORDER_DELIM $__BORDER_DELIM_DEFAULT
set --query BORDER_MIN_CMD_DURATION; or set --global BORDER_MIN_CMD_DURATION $__BORDER_MIN_CMD_DURATION_DEFAULT
set --query BORDER_MIN_COLUMNS; or set --global BORDER_MIN_COLUMNS $__BORDER_MIN_COLUMNS_DEFAULT
set --query BORDER_ALIGNMENT; or set --global BORDER_ALIGNMENT $__BORDER_ALIGNMENT_DEFAULT

set -l valid_alignments left center right
if not contains -- $BORDER_ALIGNMENT $valid_alignments
    if test $BORDER_ALIGNMENT -lt 0 -o $BORDER_ALIGNMENT -gt 1
        echo "Invalid border alignment $BORDER_ALIGNMENT"
        echo "Valid alignments: $valid_alignments"
        echo "Valid percentage alignments: 0.0 - 1.0"
        return
    end
end

set -l prefix "border.fish"

# TODO: use this
switch $BORDER_DELIM
    case ━
        set -g __BORDER_TEE_RIGHT ''
        set -g __BORDER_TEE_LEFT ''
    case ─
        set -g __BORDER_TEE_RIGHT ''
        set -g __BORDER_TEE_LEFT ''
    case ═
        set -g __BORDER_TEE_RIGHT ''
        set -g __BORDER_TEE_LEFT ''
    case -
        set -g __BORDER_TEE_RIGHT '|'
        set -g __BORDER_TEE_LEFT '|'
    case _
        set -g __BORDER_TEE_RIGHT '|'
        set -g __BORDER_TEE_LEFT '|'
        # case *
        # 	echo "Invalid border delimiter $BORDER_DELIM"
        # 	return
end

function __border_postexec --on-event fish_postexec
    set -l last_status $status
    set -l last_pipestatus $pipestatus
    test $COLUMNS -lt $BORDER_MIN_COLUMNS; and return

    set -l delim $BORDER_DELIM
    # echo "pipestatus: $PIPESTATUS"

    set -l color normal
    set -l color_text normal
    set -l text ""

    # TODO: handle pipe status

    # TODO: add rest of signals
    switch $last_status
        case 0
            set color 808080
            set -l orange "#FFA500"
            set color_text $orange
            if test $CMD_DURATION -gt $BORDER_MIN_CMD_DURATION
                set text (printf " %s " (peopletime $CMD_DURATION))
            end
            # case 1 # general error as defined by the program run
            #     set color red
            #     set color_text brred
            #     set text [EXIT CODE $last_status]
        case 2 # misuse of shell builtins (according to Bash documentation)
            set color red
            set color_text brred
            set text [$last_status invalid command invocation]
        case 127
            set color yellow
            set color_text bryellow
            set text " COMMAND NOT FOUND "
        case 130 # SIGINT (Ctrl-C) 128 + 2
            set color red
            set color_text brred
            set text [SIGINT]
        case 131 # SIGQUIT (Ctrl-\) 128 + 3
            set color red
            set color_text brred
            set text [SIGQUIT]
        case 137 # SIGKILL (kill -9) 128 + 9
            set color red
            set color_text brred
            set text [SIGKILL]
        case 139 # SIGSEGV (Segmentation fault) 128 + 11
            set color red
            set color_text brred
            set text [SIGSEGV]

        case '*'
            set color red
            set color_text brred
            set text "EXIT CODE: $last_status"
    end

    set -l text_length (string length "$text")
    if test $text_length -ge $COLUMNS
        # If the text is too long, we don't display it, as it would overflow the terminal
        set text_length 0
    end
    set -l border_length (math "$COLUMNS - $text_length")

    set -l border_left_length 0
    set -l border_right_length 0
    switch $BORDER_ALIGNMENT
        case center
            set border_left_length (math "floor($border_length / 2)")
            set border_right_length (math "ceil($border_length / 2)")
        case left
            set border_right_length $border_length
        case right
            set border_left_length $border_length
        case '*'
            # $BORDER_ALIGNMENT == 1 is the same as $BORDER_ALIGNMENT == right
            # $BORDER_ALIGNMENT == 0 is the same as $BORDER_ALIGNMENT == left
            # BORDER_ALIGNMENT_PERCENTAGE == 0.5 is the same as $BORDER_ALIGNMENT == center
            set border_left_length (math "floor($border_length * $BORDER_ALIGNMENT)")
            set border_right_length (math "$border_length - $border_left_length")
    end

    set -l border_left \
        (set_color $color) \
        (string repeat --no-newline -n $border_left_length $delim) \
        (set_color normal)

    set -l border_right \
        (set_color $color) \
        (string repeat --no-newline -n $border_right_length $delim) \
        (set_color normal)

    set text (set_color $color_text)$text(set_color normal)

    # printf then echo to properly handle newlines
    echo (printf "%s%s%s" $border_left $text $border_right)
end
