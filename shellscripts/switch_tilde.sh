#!/bin/bash
# title: switch_tilde
# date created: "2023-09-29"

set_hidutil_mapping() {
    hidutil property --set '{
    "UserKeyMapping": [
      {
        "HIDKeyboardModifierMappingSrc": 0x700000035,
        "HIDKeyboardModifierMappingDst": 0x700000064
      },
      {
        "HIDKeyboardModifierMappingSrc": 0x700000064,
        "HIDKeyboardModifierMappingDst": 0x700000035
      }
    ]
    }'
}

reset_hidutil_mapping() {
    hidutil property --set '{
    "UserKeyMapping": []
    }'
}

if [[ "$1" == "set" ]]; then
    set_hidutil_mapping
elif [[ "$1" == "reset" ]]; then
    reset_hidutil_mapping
else
    echo "Usage: $0 [set|reset]"
    exit 1
fi

exit 0

