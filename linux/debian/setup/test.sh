#!/bin/bash

runner() {
    echo "$1"
    eval "$1"
}

outer() {
    local outer1_a=1
    inner() {
        local inner1_a=2
        echo "outer1_a: $outer1_a"
        echo "inner1_a: $inner1_a"
    }
    runner 'inner'
}

outer