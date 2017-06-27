load("@io_bazel_rules_go//go:def.bzl", "go_library", "go_prefix", "go_test")

go_prefix("code.xoeb.us/cryptdo")

go_library(
    name = "go_default_library",
    srcs = [
        "crypto.go",
        "passphrase.go",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//proto:go_default_library",
        "@com_github_golang_protobuf//proto:go_default_library",
        "@org_golang_x_crypto//pbkdf2:go_default_library",
        "@org_golang_x_crypto//ssh/terminal:go_default_library",
    ],
)

go_test(
    name = "crypto",
    srcs = ["crypto_test.go"],
    deps = [
        "//:go_default_library",
        "//proto:go_default_library",
        "@com_github_golang_protobuf//proto:go_default_library",
    ],
    size = "small",
)

go_test(
    name = "roundtrip",
    srcs = ["roundtrip_test.go"],
    deps = [
        "//:go_default_library",
    ],
    size = "medium",
)
