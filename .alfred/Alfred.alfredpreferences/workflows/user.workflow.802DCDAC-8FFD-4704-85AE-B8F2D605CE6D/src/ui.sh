#!/bin/zsh --no-rcs

readonly cache="$alfred_workflow_cache"
readonly progress="${cache}/progress.txt"
readonly start="${start_speedtest:-"0"}"

stale() {
    local file="$1"
    local threshold="$2"
    local file_time=$(date -r "$file" +%s)
    local threshold_secs

    case "$threshold" in
    *s) threshold_secs=${threshold%s} ;;
    *m) threshold_secs=$((${threshold%m} * 60)) ;;
    *) threshold_secs=$threshold ;;
    esac

    local now=$(date +%s)
    local cutoff_time=$((now - threshold_secs))

    ((file_time < cutoff_time))
}

respond() {
    local response
    local strategy="${sequentially:-0}"
    case "$1" in
    confirm)
        local alternative_subtitle="⏎ Run the speedtest sequentially"
        local alternative_strategy="1"

        if [[ "$strategy" == "1" ]]; then
            alternative_subtitle="⏎ Run the speedtest concurrently"
            alternative_strategy="0"
        fi

        response=$(jq -n \
            --arg subtitle "$alternative_subtitle" \
            --arg strategy "$alternative_strategy" \
            '{ items: [
                {
                    title: "Internet Speedtest",
                    mods: {
                        cmd: {
                            subtitle: "\($subtitle)",
                            variables: {
                                sequentially: "\($strategy)"
                            }
                        }
                    }
                }
            ]}')
        ;;
    status)
        response=$(jq -n \
            --arg info "$2" \
            --arg icon "$3" \
            --arg strategy "$strategy" \
            '{ items: [
                {
                    title: "\($info)",
                    text: { largetype: "\($info)" },
                    icon: { path: "\($icon)" },
                    valid: "false"
                }
            ],
            variables: {
                sequentially: "\($strategy)"
            },
            rerun: "0.1"
        }')
        ;;
    summary|summary_long)
        while IFS= read -r line; do
            case $((++i)) in
                1) rerun_subtitle="$line" ;;
                2) alternative_subtitle="$line" ;;
                3) rerun_strategy="$line" ;;
                4) alternative_strategy="$line" ;;
            esac
        done < <(get_rerun_subtitles "$strategy")
        local common_mods=$(get_mods "$rerun_subtitle" "$rerun_strategy" "$alternative_subtitle" "$alternative_strategy")
        case "$1" in
        summary)
            response=$(jq -n \
                --arg title "$2" \
                --arg subtitle "$3" \
                --argjson mods "$common_mods" \
                '{ items: [
                    {
                        title: $title,
                        subtitle: $subtitle,
                        text: {
                            copy: "\($title) \($subtitle)",
                            largetype: "\($title) \($subtitle)"
                        },
                        icon: { path: "images/icons/success.png" },
                        valid: "false",
                        mods: $mods
                    }
                ]}')
            ;;
        summary_long)
            response=$(jq -n \
                --arg title "$2" \
                --arg responsiveness_up "${3%%:*}" \
                --arg responsiveness_up_sub "${${3#*:}## }" \
                --arg responsiveness_down "${4%%:*}" \
                --arg responsiveness_down_sub "${${4#*:}## }" \
                --arg idle_latency "${5%%:*}" \
                --arg idle_latency_sub "${${5#*:}## }" \
                --argjson mods "$common_mods" \
                '
                def detail_item($title; $subtitle):
                {
                    title: $title,
                    subtitle: $subtitle,
                    icon: { path: "images/icons/blank.png" },
                    text: {
                        copy: "\($title): \($subtitle)",
                        largetype: "\($title): \($subtitle)"
                    },
                    valid: "false"
                };

                { items: [
                    {
                        title: $title,
                        text: {
                            copy: $title,
                            largetype: $title
                        },
                        icon: { path: "images/icons/success.png" },
                        valid: "false",
                        mods: $mods
                    },
                    detail_item($responsiveness_down; $responsiveness_down_sub),
                    detail_item($responsiveness_up; $responsiveness_up_sub),
                    detail_item($idle_latency; $idle_latency_sub)
                ]}')
            ;;
        esac
        ;;
    error)
        response=$(jq -n \
            --arg error_message "$2" \
            --arg strategy "$strategy" \
            '{ items: [
                {
                    title: "There was an error testing the network quality",
                    subtitle: "Retrying shortly...",
                    text: {
                        copy: "\($error_message)",
                        largetype: "\($error_message)"
                    },
                    icon: { path: "images/icons/warmup.png" },
                    valid: "false"
                }
            ],
            variables: {
                start_speedtest: "1",
                sequentially: $strategy
            },
            rerun: "3.0"
        }')
        ;;
    *)
        response=$(jq -n \
            --arg argument "${1:-None}" \
            '{ items: [
                {
                    title: "Speedtest Failure",
                    subtitle: "Invalid argument '\''\($argument)'\''",
                    valid: "false"
                }
            ]}')
        ;;
    esac

    echo "$response"
}

get_rerun_subtitles() {
    local strategy="$1"
    local rerun_subtitle="⏎ Rerun the speedtest"
    local alternative_subtitle="$rerun_subtitle"

    if [[ "$strategy" == "1" ]]; then
        rerun_subtitle+=" sequentially"
        alternative_subtitle+=" concurrently"
        printf "%s\n%s\n1\n0" "$rerun_subtitle" "$alternative_subtitle"
    else
        rerun_subtitle+=" concurrently"
        alternative_subtitle+=" sequentially"
        printf "%s\n%s\n0\n1" "$rerun_subtitle" "$alternative_subtitle"
    fi
}

get_mods() {
    local cmd_subtitle="$1"
    local cmd_strategy="$2"
    local cmd_shift_subtitle="$3"
    local cmd_shift_strategy="$4"

    jq -n \
        --arg cmd_subtitle "$cmd_subtitle" \
        --arg cmd_strategy "$cmd_strategy" \
        --arg cmd_shift_subtitle "$cmd_shift_subtitle" \
        --arg cmd_shift_strategy "$cmd_shift_strategy" \
        '{
            cmd: {
                valid: "true",
                subtitle: $cmd_subtitle,
                icon: { path: "images/icons/warmup.png" },
                variables: {
                    sequentially: $cmd_strategy
                }
            },
            "cmd+shift": {
                valid: "true",
                subtitle: $cmd_shift_subtitle,
                icon: { path: "images/icons/warmup.png" },
                variables: {
                    sequentially: $cmd_shift_strategy
                }
            }
        }'
}

get_icon() {
    local speed=$1
    local icon_name

    speed=${speed%.*} # Remove decimal part

    case $((speed)) in
    [0-9]) icon_name="images/icons/tacho1.png" ;;
    1[0-9]) icon_name="images/icons/tacho2.png" ;;
    2[0-9]) icon_name="images/icons/tacho3.png" ;;
    3[0-9]) icon_name="images/icons/tacho4.png" ;;
    4[0-9]) icon_name="images/icons/tacho5.png" ;;
    5[0-9]) icon_name="images/icons/tacho6.png" ;;
    6[0-9]) icon_name="images/icons/tacho7.png" ;;
    7[0-9]) icon_name="images/icons/tacho8.png" ;;
    8[0-9]) icon_name="images/icons/tacho9.png" ;;
    *) icon_name="images/icons/tacho10.png" ;;
    esac

    echo "$icon_name"
}

get_value() {
    local value="$1"
    if [[ $shorter_values -eq 1 ]]; then
        case "$2" in
        ms) value=$(printf "%.0f" "$1") ;; # No decimals for ms
        s) value=$(printf "%.1f" "$1") ;;  # One decimal for seconds
        esac
    fi
    echo "$value"
}

get_metric() {
    local metric="$1"
    case "$1" in
    milliseconds) metric="ms" ;;
    seconds) metric="s" ;;
    esac
    echo "$metric"
}

readonly CAPACITY_REGEX='Uplink capacity: ([0-9.]+) Mbps.*Downlink capacity: ([0-9.]+) Mbps'
readonly RESPONSIVENESS_REGEX='Responsiveness: (Low|Medium|High) \(([0-9.]+) (milliseconds|seconds) \| ([0-9]+) RPM\)'
readonly RESPONSIVENESS_UP_REGEX='Uplink Responsiveness: (Low|Medium|High) \(([0-9.]+) (milliseconds|seconds) \| ([0-9]+) RPM\)'
readonly RESPONSIVENESS_DOWN_REGEX='Downlink Responsiveness: (Low|Medium|High) \(([0-9.]+) (milliseconds|seconds) \| ([0-9]+) RPM\)'
readonly IDLE_REGEX='Idle Latency: ([0-9.]+) (milliseconds|seconds) \| ([0-9]+) RPM' # RPM = Round-trips Per Minute

parse_parallel() {
    local summary="$1"
    local title subtitle

    if [[ $summary =~ $CAPACITY_REGEX ]]; then
        title="Download: ${match[2]} Mbps  |  Upload: ${match[1]} Mbps"
    else
        throw "Incomplete Results: Missing Up-/ Downlink capacity."
    fi

    if [[ $summary =~ $RESPONSIVENESS_REGEX ]]; then
        metric="$(get_metric "${match[3]}")"
        responsiveness="$(get_value "${match[2]}" $metric) $metric"
        subtitle="Responsiveness: ${match[1]} ($responsiveness | ${match[4]} RPM)"
    else
        throw "Incomplete Results: Missing Responsiveness."
    fi

    if [[ $summary =~ $IDLE_REGEX ]]; then
        metric="$(get_metric "${match[2]}")"
        idle_latency="$(get_value "${match[1]}" $metric) $metric"
        subtitle+=" · Idle Latency: $idle_latency | ${match[3]} RPM"
    else
        throw "Incomplete Results: Missing Idle Latency."
    fi

    respond summary "$title" "$subtitle"
}

parse_sequential() {
    local summary="$1"
    local title subtitle
    local uplink downlink idle

    if [[ $summary =~ $CAPACITY_REGEX ]]; then
        title="Download: ${match[2]} Mbps  |  Upload: ${match[1]} Mbps"
    else
        throw "Incomplete Results: Missing Up-/ Downlink capacity."
    fi

    if [[ $summary =~ $RESPONSIVENESS_UP_REGEX ]]; then
        up_metric="$(get_metric "${match[3]}")"
        up_responsiveness="$(get_value "${match[2]}" $up_metric) $up_metric"
        subtitle="Up: ${match[1]} ($up_responsiveness | ${match[4]} RPM)"
        uplink="Uplink Responsiveness: ${match[1]} (${match[2]} ${match[3]} | ${match[4]} RPM)"
    else
        throw "Incomplete Results: Missing Uplink Responsiveness."
    fi

    if [[ $summary =~ $RESPONSIVENESS_DOWN_REGEX ]]; then
        down_metric="$(get_metric "${match[3]}")"
        down_responsiveness="$(get_value "${match[2]}" $down_metric) $down_metric"
        subtitle+=" · Down: ${match[1]} ($down_responsiveness | ${match[4]} RPM)"
        downlink="Downlink Responsiveness: ${match[1]} (${match[2]} ${match[3]} | ${match[4]} RPM)"
    else
        throw "Incomplete Results: Missing Downlink Responsiveness."
    fi

    if [[ $summary =~ $IDLE_REGEX ]]; then
        metric="$(get_metric "${match[2]}")"
        idle_latency="$(get_value "${match[1]}" $metric) $metric"
        subtitle+=" · Idle: $idle_latency | ${match[3]} RPM"
        idle="Idle Latency: ${match[1]} ${match[2]} | ${match[3]} RPM"
    else
        throw "Incomplete Results: Missing Idle Latency."
    fi

    case "${display:-compact}" in
        compact)
            respond summary "$title" "$subtitle"
            ;;
        verbose)
            respond summary_long "$title" "$uplink" "$downlink" "$idle"
            ;;
    esac

}

is_sequential_result() {
    local summary="$1"
    [[ "$summary" =~ "Uplink Responsiveness:" && "$summary" =~ "Downlink Responsiveness:" ]]
}

throw() {
    mv "$progress" "$progress.bak.txt" # debug
    rm "$progress"
    respond error "$1"
    exit 0
}

# main

if [[ ! -d "$cache" ]]; then
    mkdir -p "$cache"
fi

if [[ -f "$progress" ]] && stale "$progress" "${freshness}m"; then
    echo >&2 "Removing stale progress file"
    rm "$progress"
fi

if [[ ! -f "$progress" ]]; then
    if [[ $start -eq 1 ]]; then
        osascript -e 'tell application id "com.runningwithcrayons.Alfred" to run trigger "run_speedtest" in workflow "com.zeitlings.internet.speedtest"'
        exit 0
    else
        respond confirm
    fi
else

    cleaned_output=$(cat "$progress" |
        perl -pe 's/\r/\n/g' |   # Replace carriage return with newline
        perl -pe 's/\e\[2K//g' | # Remove terminal control sequences
        perl -pe 's/\^D//g' |    # Remove ^D literal
        perl -pe 's///g' |      # Remove control character
        grep -v '^$')            # Remove empty lines

    last_line=$(echo "$cleaned_output" | tail -n 1)
    # Sequential execution often trails valid results with errors
    second_last_line=$(echo "$cleaned_output" | tail -n 2 | head -n 1)

    echo >&2 "$last_line"

    if [[ $last_line =~ 'Downlink: ([0-9.]+) Mbps, ([0-9]+) RPM - Uplink: ([0-9.]+) Mbps, ([0-9]+) RPM' ]]; then

        icon=$(get_icon "${match[1]}")
        current_progress="↓ ${match[1]} Mbps (${match[2]} RPM)  ↑ ${match[3]} Mbps (${match[4]} RPM)"
        respond status "$current_progress" "$icon"

        # TODO: Current strategy memory to ensure identical rerun behavior over new sessions that threw
        # Catches both successful cases:
        # - Clean completion (last line is Idle Latency or Responsiveness)
        # - Completion with trailing error (second last line is Idle Latency)
    elif [[ "$last_line" == "Idle Latency:"* || "$last_line" == "Responsiveness"* || "$second_last_line" == "Idle Latency:"* ]]; then
        summary=$(echo "$cleaned_output" | tail -n 6) # extra line where run sequentially, and result contains false negative error

        if is_sequential_result "$summary"; then
            parse_sequential "$summary"
        else
            parse_parallel "$summary"
        fi

    elif [[ "$last_line" == "Error"* || "$last_line" == *"NSLocalizedDescription"* ]]; then
        throw "$last_line"
    else
        respond status "Internet Speedtest..." "images/icons/warmup.png" # init

    fi

fi
